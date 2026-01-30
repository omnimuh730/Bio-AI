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
import traceback
import time
from contextlib import contextmanager

# Small helper for consistent, flushed logs
def p(msg):
    print(f"[detect] {msg}", flush=True)

@contextmanager
def timed_step(name):
    start = time.perf_counter()
    p(f"⏱ START: {name}")
    try:
        yield
    finally:
        elapsed = time.perf_counter() - start
        p(f"⏱ DONE: {name} — {elapsed:.2f}s")


# --- CONFIGURATION ---
PIXELS_PER_CM = 38.0
FONT_SIZE = 10
OUTPUT_FOLDER = "Extracted_Ingredients"
JSON_OUTPUT_FILE = "nutrition_report.json"

# Prefer server-local model weights directory when available
MODEL_DIR = Path(__file__).parent / "models"
SAM_WEIGHTS = MODEL_DIR / "FastSAM-x.pt" if (MODEL_DIR / "FastSAM-x.pt").exists() else "FastSAM-x.pt"

# --- FINE TUNING PARAMETERS ---
CONF_THRESHOLD = 0.2
IOU_THRESHOLD = 0.5
RETINA_MASKS = True

# --- AI MODEL CONFIG ---
# Using OpenAI for vision-language analysis (model: gpt-5-nano-2025-08-07) when available.

try:
    from ultralytics import SAM
    from transformers import pipeline
    # qwen-specific processors not required when using OpenAI
except ImportError as e:
    p(f"Missing libraries for segmentation/depth pipeline: {e}")
    p("Run: pip install ultralytics transformers torch opencv-python pillow accelerate")
    sys.exit(1)

# ==========================================
# 1. COMPUTER VISION SECTION (SAM + DEPTH)
# ==========================================

def get_depth_map(pil_image):
    """Generates a normalized depth map (0.0 to 1.0)."""
    p("Loading depth estimation model...")
    device = 0 if torch.cuda.is_available() else -1
    try:
        depth_estimator = pipeline(task="depth-estimation", model="LiheYoung/depth-anything-small-hf", device=device)
        depth_result = depth_estimator(pil_image)
        depth_map = np.array(depth_result["depth"])
    except Exception as e:
        p(f"Depth model failed: {e}")
        p(traceback.format_exc())
        raise
    
    # Normalize
    d_min, d_max = depth_map.min(), depth_map.max()
    depth_norm = (depth_map - d_min) / (d_max - d_min)
    
    # Cleanup to save VRAM for Qwen later
    try:
        del depth_estimator
        torch.cuda.empty_cache()
    except Exception:
        pass
    
    p("Depth map ready")
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
    p(f"Saved: {file_name}")

    # Return structured data for analysis
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
        # Use OpenAI Responses API (gpt-5-nano-2025-08-07) for analysis when available.
        p("Initializing NutrientScanner (OpenAI)...")
        self.client = None
        self.model = "gpt-5-nano-2025-08-07"
        self.openai_key = os.getenv("OPENAI_KEY") or os.getenv("OPENAI_API_KEY")
        if not self.openai_key:
            p("⚠️ OPENAI_KEY not set; NutrientScanner will be unavailable.")
            return
        try:
            # Try modern OpenAI client
            try:
                from openai import OpenAI
                self.client = OpenAI(api_key=self.openai_key)
            except Exception:
                import openai
                openai.api_key = self.openai_key
                self.client = openai
            p("OpenAI client initialized.")
        except Exception as e:
            p(f"Error initializing OpenAI client: {e}")
            p(traceback.format_exc())
            self.client = None

    def analyze_item(self, item_data):
        """Send physics data + image path to OpenAI to request JSON nutritional analysis.

        Note: For now we pass the server-local image path and physics metrics in the prompt.
        A future improvement would upload the cropped image via the OpenAI files API and reference it
        so the model can see the image pixels directly.
        """
        image_path = item_data.get("image_path")
        vol = item_data.get("volume_ml")
        area = item_data.get("area_cm2")
        item_id = item_data.get("id")

        prompt_text = (
            f"You are an expert food scientist. Identify this cropped food item.\n"
            f"Server image path (for reference): {image_path}\n"
            f"Precise Physics Sensors Data:\n"
            f"- Volume: {vol} ml\n"
            f"- Surface Area: {area} cm^2\n\n"
            f"Based on the visual texture (image provided) and this volume, provide a JSON output.\n"
            f"Instructions:\n"
            f"1. Name the food precisely.\n"
            f"2. Estimate total calories for this specific volume.\n"
            f"3. Break down protein, fat, carbs (in grams).\n"
            f"4. Provide a short reasoning based on the visual and volume.\n\n"
            f"Output strictly valid JSON format like this:\n"
            "{\n  \"name\": \"...\",\n  \"calories\": 0,\n  \"macros\": {\"p\": \"0g\", \"f\": \"0g\", \"c\": \"0g\"},\n  \"reasoning\": \"...\"\n}"
        )

        if not self.client:
            return {"error": "openai_not_configured", "message": "OPENAI_KEY missing or client init failed"}

        try:
            p(f"Querying OpenAI for {item_id} (Vol: {vol}ml)...")
            # Use the Responses API where available
            try:
                # Modern OpenAI client (recommended)
                resp = self.client.responses.create(
                    model=self.model,
                    input=prompt_text,
                    max_output_tokens=512,
                    temperature=0.1,
                )
                # Extract text
                out_text = None
                if hasattr(resp, 'output') and resp.output:
                    # resp.output is a list of output objects
                    parts = []
                    for o in resp.output:
                        if isinstance(o, dict) and 'content' in o:
                            for c in o['content']:
                                if c.get('type') == 'output_text' and c.get('text'):
                                    parts.append(c['text'])
                    out_text = '\n'.join(parts) if parts else None
                if out_text is None:
                    # Fallback to str(resp)
                    out_text = getattr(resp, 'output_text', None) or str(resp)
            except Exception as e:
                # Fallback for classic openai library usage
                try:
                    resp = self.client.ChatCompletion.create(
                        model=self.model,
                        messages=[{"role": "user", "content": prompt_text}],
                        max_tokens=512,
                        temperature=0.1,
                    )
                    out_text = resp.choices[0].message.content
                except Exception as e2:
                    p(f"OpenAI request failed: {e2}")
                    p(traceback.format_exc())
                    return {"error": "openai_request_failed", "message": str(e2)}

            # Try to find JSON in out_text
            response_text = out_text.strip() if out_text else ''
            # Clean code-fence
            if response_text.startswith('```'):
                response_text = response_text.split('\n', 1)[-1]
                if response_text.endswith('```'):
                    response_text = response_text[:-3]

            try:
                data = json.loads(response_text)
                data['measured_volume_ml'] = vol
                data['measured_area_cm2'] = area
                data['source_image'] = image_path
                return data
            except json.JSONDecodeError:
                return {"error": "failed_parse", "raw_output": response_text}

        except Exception as e:
            p(f"Error during OpenAI analysis: {e}")
            p(traceback.format_exc())
            return {"error": "openai_error", "message": str(e)}

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

    p(f"⏳ Processing Image: {image_path}")
    start_time = time.perf_counter()

    # 1. Load Image
    original_cv2 = cv2.imread(image_path)
    if original_cv2 is None:
        p("Error loading image.")
        return

    composite_image = original_cv2.copy()
    img_h, img_w = original_cv2.shape[:2]
    original_pil = Image.fromarray(cv2.cvtColor(original_cv2, cv2.COLOR_BGR2RGB))

    # 2. Get Depth Map
    try:
        with timed_step("Depth estimation"):
            depth_map = get_depth_map(original_pil)
            depth_map_resized = cv2.resize(depth_map, (img_w, img_h))
    except Exception as e:
        p(f"Depth estimation failed: {e}")
        return

    # 3. Run SAM / FastSAM
    p(f"⏳ Running Segmentation (Conf: {CONF_THRESHOLD}, IoU: {IOU_THRESHOLD})...")
    p(f"Using SAM weights: {SAM_WEIGHTS}")

    masks_data = None
    model = None
    results = None

    try:
        sam_weight_name = str(SAM_WEIGHTS).lower()
        # If FastSAM weights requested, use fastsam package
        if "fastsam" in sam_weight_name or "fast-sam" in sam_weight_name or sam_weight_name.endswith('.pt') and 'fast' in os.path.basename(sam_weight_name):
            try:
                from fastsam import FastSAM
            except Exception:
                p("FastSAM weights requested but `fastsam` package is not installed.")
                p("Install with: pip install fastsam or git+https://github.com/yang-song/fastsam.git")
                raise

            with timed_step("FastSAM segmentation"):
                p("Loading FastSAM model...")
                model = FastSAM(str(SAM_WEIGHTS))
                device = "cuda" if torch.cuda.is_available() else "cpu"
                # Predict; try a few common argument names for compatibility
                try:
                    fs_results = model.predict(original_cv2, device=device, retina_masks=RETINA_MASKS)
                except TypeError:
                    fs_results = model.predict(original_cv2, device=device)

                # Extract masks robustly
                fast_masks = None
                if hasattr(fs_results, 'masks'):
                    fast_masks = fs_results.masks
                elif isinstance(fs_results, dict) and 'masks' in fs_results:
                    fast_masks = fs_results['masks']
                elif isinstance(fs_results, (list, tuple)) and len(fs_results) > 0 and hasattr(fs_results[0], 'masks'):
                    fast_masks = fs_results[0].masks

                if fast_masks is None:
                    # Try common attribute names
                    if hasattr(fs_results, 'segmentation'):
                        fast_masks = fs_results.segmentation

                # Convert to numpy (N, H, W) uint8
                if fast_masks is None:
                    raise RuntimeError('Could not extract masks from FastSAM results')

                if isinstance(fast_masks, torch.Tensor):
                    masks_data = fast_masks.cpu().numpy().astype('uint8')
                elif isinstance(fast_masks, np.ndarray):
                    masks_data = fast_masks.astype('uint8')
                else:
                    # assume iterable of masks
                    masks_data = np.stack([np.array(m, dtype='uint8') for m in fast_masks], axis=0)

        else:
            with timed_step("SAM segmentation"):
                model = SAM(str(SAM_WEIGHTS))
                results = model(image_path, retina_masks=RETINA_MASKS, conf=CONF_THRESHOLD, iou=IOU_THRESHOLD, verbose=False)

            if not results or not getattr(results[0], 'masks', None):
                p("❌ No objects detected.")
                return

            masks_data = results[0].masks.data.cpu().numpy().astype('uint8')

    except Exception as e:
        p(f"SAM segmentation failed: {e}")
        p(traceback.format_exc())
        return

    if masks_data is None or masks_data.size == 0:
        p("❌ No masks extracted.")
        return

    p(f"✅ Found {masks_data.shape[0]} mask(s).")

    # Clean up models to free memory
    try:
        if 'model' in locals() and model is not None:
            del model
        if 'results' in locals() and results is not None:
            del results
        gc.collect()
        torch.cuda.empty_cache()
    except Exception:
        pass

    # --- Accumulator for the "Rest" item ---
    total_mask_accumulator = np.zeros((img_h, img_w), dtype=np.uint8)

    items = []

    count = 0
    p(f"✅ Extracting items...")

    for i, mask in enumerate(masks_data):
        with timed_step(f"Item {i+1} processing"):
            # --- Filter Noise ---
            mask_area_pixels = mask.sum()
            total_pixels = img_w * img_h

            if mask_area_pixels < (total_pixels * 0.0001) or mask_area_pixels > (total_pixels * 0.9):
                p(f"Skipping item {i+1}: area {mask_area_pixels} px")
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
                items.append(item_data)

            count += 1

    # --- PROCESS THE REST (BACKGROUND) ---
    p("⏳ Calculating the 'Rest'...")
    rest_mask = 1 - total_mask_accumulator

    with timed_step("Background / Rest"):
        if rest_mask.sum() > 0:
            rest_data = save_single_item(
                rest_mask, original_pil, depth_map_resized, img_w, img_h,
                output_dir,
                f"item_rest.png",
                "Background / Rest"
            )
            if rest_data:
                items.append(rest_data)

    # Apply grey overlay to rest area in composite
    grey_layer = np.full_like(original_cv2, 100, dtype=np.uint8)
    rest_indices = rest_mask == 1
    composite_image[rest_indices] = cv2.addWeighted(
        composite_image[rest_indices], 0.7,
        grey_layer[rest_indices], 0.3,
        0
    )

    # Save Total Image
    with timed_step("Save composite image"):
        total_image_path = output_dir / "TOTAL_SUMMARY.jpg"
        cv2.imwrite(str(total_image_path), composite_image)
        p(f"   -> Saved Composite Image: {total_image_path}")

    # Save simple JSON report with volumes/areas
    json_path = output_dir / JSON_OUTPUT_FILE
    try:
        with timed_step("Write JSON report"):
            with open(json_path, 'w') as f:
                json.dump(items, f, indent=4)
        p(f"✨ COMPLETE! Physics data saved to: {json_path}")
    except Exception as e:
        p(f"Failed to write JSON report: {e}")

    total_elapsed = time.perf_counter() - start_time
    p(f"⏱ TOTAL processing time: {total_elapsed:.2f}s")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", default="food.jpg")
    args = parser.parse_args()

    image_path = Path(args.image)
    if not image_path.exists():
        p("Image not found.")
        return

    process_and_extract(str(image_path))

if __name__ == "__main__":
    main()