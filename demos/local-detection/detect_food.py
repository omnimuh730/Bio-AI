import argparse
import sys
import random
import json
import os
import gc
from pathlib import Path
import cv2
import numpy as np
import torch
from PIL import Image, ImageDraw, ImageFont

# --- CONFIGURATION ---
PIXELS_PER_CM = 38.0
FONT_SIZE = 14
OUTPUT_FOLDER = "Extracted_Ingredients"
JSON_OUTPUT_FILE = "nutrition_report.json"

# --- FINE TUNING PARAMETERS ---
CONF_THRESHOLD = 0.05
IOU_THRESHOLD = 0.3
RETINA_MASKS = True

# --- AI MODEL CONFIG ---
# User requested Qwen 2.5 3B Instruct
QWEN_MODEL_PATH = "Qwen/Qwen2.5-VL-3B-Instruct"

try:
    from ultralytics import SAM
    from transformers import pipeline, Qwen2_5_VLForConditionalGeneration, AutoProcessor
    from qwen_vl_utils import process_vision_info
except ImportError:
    print("Missing libraries.")
    print("Run: pip install ultralytics transformers torch opencv-python pillow qwen-vl-utils accelerate")
    sys.exit(1)

# ==========================================
# 1. COMPUTER VISION SECTION (SAM + DEPTH)
# ==========================================

def get_depth_map(pil_image):
    """Generates a normalized depth map (0.0 to 1.0)."""
    print("⏳ Loading Depth Model...")
    device = 0 if torch.cuda.is_available() else -1
    depth_estimator = pipeline(task="depth-estimation", model="LiheYoung/depth-anything-small-hf", device=device)
    depth_result = depth_estimator(pil_image)
    depth_map = np.array(depth_result["depth"])
    
    # Normalize
    d_min, d_max = depth_map.min(), depth_map.max()
    depth_norm = (depth_map - d_min) / (d_max - d_min)
    
    # Cleanup to save VRAM for Qwen later
    del depth_estimator
    torch.cuda.empty_cache()
    
    return depth_norm

def draw_info_box(draw, text, x, y):
    """Draws a text box with a background."""
    try:
        font = ImageFont.truetype("arial.ttf", FONT_SIZE)
    except IOError:
        font = ImageFont.load_default()
        
    bbox = draw.textbbox((x, y), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    
    padding = 5
    draw.rectangle(
        [x - padding, y - padding, x + text_w + padding, y + text_h + padding], 
        fill=(30, 30, 30, 200) 
    )
    draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))

def save_single_item(mask, original_pil, depth_map_resized, img_w, img_h, output_dir, file_name, label_title):
    """
    Calculates physics, saves PNG, and RETURNS data for Qwen analysis.
    """
    
    # --- Calculate Physics ---
    mask_area_pixels = mask.sum()
    real_area_cm2 = mask_area_pixels / (PIXELS_PER_CM ** 2)
    
    obj_depths = depth_map_resized[mask == 1]
    if len(obj_depths) == 0: return None

    local_min_depth = np.min(obj_depths)
    avg_height_factor = (np.mean(obj_depths) - local_min_depth) 
    if avg_height_factor < 0.01: avg_height_factor = 0.01
    
    estimated_height_cm = avg_height_factor * 25.0
    estimated_vol_ml = real_area_cm2 * estimated_height_cm * 2.0 

    # --- Create Transparent PNG ---
    alpha_mask = Image.fromarray(mask * 255, mode='L')
    item_img = original_pil.convert("RGBA")
    item_img.putalpha(alpha_mask)
    
    bbox = alpha_mask.getbbox()
    if not bbox: return None
    
    pad = 10
    crop_box = (max(0, bbox[0]-pad), max(0, bbox[1]-pad), min(img_w, bbox[2]+pad), min(img_h, bbox[3]+pad))
    cropped_img = item_img.crop(crop_box)
    
    # --- Draw Info ---
    draw = ImageDraw.Draw(cropped_img)
    data_text = f"Vol: {estimated_vol_ml:.1f} ml\nArea: {real_area_cm2:.1f} cm2"
    draw_info_box(draw, label_title, 10, 10)
    draw_info_box(draw, data_text, 10, 35)

    save_path = output_dir / file_name
    cropped_img.save(save_path)
    print(f"   -> Saved: {file_name}")

    # Return structured data for Qwen
    return {
        "id": label_title,
        "image_path": str(save_path),
        "volume_ml": float(f"{estimated_vol_ml:.1f}"),
        "area_cm2": float(f"{real_area_cm2:.1f}")
    }

# ==========================================
# 2. VISION LANGUAGE MODEL (QWEN) SECTION
# ==========================================

class NutrientScanner:
    def __init__(self):
        print(f"\n⏳ Loading AI Model: {QWEN_MODEL_PATH}...")
        print("   (This may take a moment and requires ~16GB+ VRAM for 3B)")
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
        try:
            self.model = Qwen2_5_VLForConditionalGeneration.from_pretrained(
                QWEN_MODEL_PATH,
                torch_dtype=torch.bfloat16,
                device_map="auto",
                attn_implementation="sdpa" # Optimized for RTX 30/40 series
            )
            self.processor = AutoProcessor.from_pretrained(QWEN_MODEL_PATH)
        except Exception as e:
            print(f"❌ Error loading Qwen: {e}")
            sys.exit(1)

    def analyze_item(self, item_data):
        """
        Sends the cropped image + physics data to Qwen for JSON analysis.
        """
        image_path = item_data["image_path"]
        vol = item_data["volume_ml"]
        area = item_data["area_cm2"]
        item_id = item_data["id"]

        prompt_text = (
            f"You are an expert food scientist. Identify this cropped food item.\n"
            f"Precise Physics Sensors Data:\n"
            f"- Volume: {vol} ml\n"
            f"- Surface Area: {area} cm²\n\n"
            f"Based on the visual texture and this volume, provide a JSON output.\n"
            f"Instructions:\n"
            f"1. Name the food precisely.\n"
            f"2. Estimate total calories for this specific volume.\n"
            f"3. Break down protein, fat, carbs (in grams).\n"
            f"4. Provide a short reasoning based on the visual and volume.\n\n"
            f"Output strictly valid JSON format like this:\n"
            f"{{ 'name': '...', 'calories': 0, 'macros': {{'p': '0g', 'f': '0g', 'c': '0g'}}, 'reasoning': '...' }}"
        )

        messages = [
            {
                "role": "user",
                "content": [
                    {"type": "image", "image": image_path},
                    {"type": "text", "text": prompt_text},
                ],
            }
        ]

        text = self.processor.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
        image_inputs, video_inputs = process_vision_info(messages)
        
        inputs = self.processor(
            text=[text],
            images=image_inputs,
            padding=True,
            return_tensors="pt",
        )
        inputs = inputs.to(self.device)

        # Generate response
        print(f"   🧠 Analyzing {item_id} (Vol: {vol}ml)...")
        generated_ids = self.model.generate(**inputs, max_new_tokens=200, temperature=0.1)
        
        output_text = self.processor.batch_decode(
            generated_ids, skip_special_tokens=True
        )[0]
        
        # Extract JSON part
        response_text = output_text.split("assistant\n")[-1].strip()
        if response_text.startswith("```json"):
            response_text = response_text.replace("```json", "").replace("```", "")
        
        try:
            data = json.loads(response_text)
            # Merge our physics data into the final result
            data["measured_volume_ml"] = vol
            data["measured_area_cm2"] = area
            data["source_image"] = image_path
            return data
        except json.JSONDecodeError:
            return {
                "error": "Failed to parse JSON",
                "raw_output": response_text,
                "measured_volume_ml": vol
            }

# ==========================================
# 3. MAIN WORKFLOW
# ==========================================

def process_and_extract(image_path):
    output_dir = Path(OUTPUT_FOLDER)
    output_dir.mkdir(exist_ok=True)
    
    # Clean old files
    for f in output_dir.glob("*.png"): f.unlink()
    for f in output_dir.glob("*.jpg"): f.unlink()
    for f in output_dir.glob("*.json"): f.unlink()
    
    print(f"⏳ Processing Image: {image_path}")
    
    # 1. Load Image
    original_cv2 = cv2.imread(image_path)
    if original_cv2 is None:
        print("Error loading image.")
        return
    
    composite_image = original_cv2.copy()
    img_h, img_w = original_cv2.shape[:2]
    original_pil = Image.fromarray(cv2.cvtColor(original_cv2, cv2.COLOR_BGR2RGB))
    
    # 2. Get Depth Map
    depth_map = get_depth_map(original_pil)
    depth_map_resized = cv2.resize(depth_map, (img_w, img_h))

    # 3. Run SAM
    print(f"⏳ Running Segmentation (Conf: {CONF_THRESHOLD}, IoU: {IOU_THRESHOLD})...")
    model = SAM('sam_b.pt') # You can change to 'sam_l.pt' if you downloaded it
    results = model(image_path, retina_masks=RETINA_MASKS, conf=CONF_THRESHOLD, iou=IOU_THRESHOLD, verbose=False)
    
    if not results[0].masks:
        print("❌ No objects detected.")
        return

    masks_data = results[0].masks.data.cpu().numpy().astype('uint8') 

    # Clean up SAM model to free memory for Qwen
    del model
    del results
    gc.collect()
    torch.cuda.empty_cache()

    # --- Accumulator for the "Rest" item ---
    total_mask_accumulator = np.zeros((img_h, img_w), dtype=np.uint8)

    # List to hold data for AI analysis later
    items_to_analyze = []

    count = 0
    print(f"✅ Extracting items...")

    for i, mask in enumerate(masks_data):
        
        # --- Filter Noise ---
        mask_area_pixels = mask.sum()
        total_pixels = img_w * img_h
        
        if mask_area_pixels < (total_pixels * 0.0001) or mask_area_pixels > (total_pixels * 0.9):
            continue
        
        total_mask_accumulator = np.maximum(total_mask_accumulator, mask)

        # Update Composite Image
        color = np.random.randint(0, 255, (3,), dtype=np.uint8).tolist()
        colored_layer = np.zeros_like(original_cv2, dtype=np.uint8)
        colored_layer[mask == 1] = color
        
        mask_indices = mask == 1
        composite_image[mask_indices] = cv2.addWeighted(
            composite_image[mask_indices], 0.6, 
            colored_layer[mask_indices], 0.4, 
            0
        )
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(composite_image, contours, -1, color, 2)

        # Save and collect data
        item_data = save_single_item(
            mask, original_pil, depth_map_resized, img_w, img_h, 
            output_dir, 
            f"item_{count+1}.png", 
            f"Item {count+1}"
        )
        if item_data:
            items_to_analyze.append(item_data)
        
        count += 1

    # --- PROCESS THE REST (BACKGROUND) ---
    print("⏳ Calculating the 'Rest'...")
    rest_mask = 1 - total_mask_accumulator
    
    if rest_mask.sum() > 0:
        rest_data = save_single_item(
            rest_mask, original_pil, depth_map_resized, img_w, img_h,
            output_dir,
            f"item_rest.png",
            "Background / Rest"
        )
        if rest_data:
            items_to_analyze.append(rest_data)
        
        grey_layer = np.full_like(original_cv2, 100, dtype=np.uint8)
        rest_indices = rest_mask == 1
        composite_image[rest_indices] = cv2.addWeighted(
            composite_image[rest_indices], 0.7,
            grey_layer[rest_indices], 0.3,
            0
        )

    # Save Total Image
    total_image_path = output_dir / "TOTAL_SUMMARY.jpg"
    cv2.imwrite(str(total_image_path), composite_image)
    print(f"   -> Saved Composite Image: {total_image_path}")

    # ==========================================
    # 4. RUN AI ANALYSIS
    # ==========================================
    
    if items_to_analyze:
        print("\n🚀 Starting Qwen2.5-VL-3B Nutritional Analysis...")
        
        # Initialize Scanner (Loads model into VRAM)
        scanner = NutrientScanner()
        final_report = []

        for item in items_to_analyze:
            # Run inference
            ai_result = scanner.analyze_item(item)
            final_report.append(ai_result)

        # Save JSON
        json_path = output_dir / JSON_OUTPUT_FILE
        with open(json_path, "w") as f:
            json.dump(final_report, f, indent=4)
            
        print(f"\n✨ COMPLETE! Nutrition Data saved to: {json_path}")
    else:
        print("No items found to analyze.")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", default="food.jpg")
    args = parser.parse_args()

    image_path = Path(args.image)
    if not image_path.exists():
        print("Image not found.")
        return

    process_and_extract(str(image_path))

if __name__ == "__main__":
    main()