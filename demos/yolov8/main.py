"""
RF-DETR-XXL (2XLarge) based material-level patch extraction and clustering

Usage:
    python main.py --image food.jpg --k 6 --area-min 120 --conf-thres 0.25

Outputs are written to ./results/<image-stem>/ with:
 - patched crops saved as PNG
 - overlay visualization `overlay.png`
 - `patches.csv` describing each patch and its cluster
"""

import argparse
import os
import sys
import time
from pathlib import Path

# --- START COMPATIBILITY PATCH ---
# This fixes the "ImportError: cannot import name 'find_pruneable_heads_and_indices'"
# by injecting the missing functions into transformers.pytorch_utils
try:
    import torch
    from torch import nn
    import transformers.pytorch_utils

    def find_pruneable_heads_and_indices(heads, n_heads, head_size, already_pruned_heads):
        mask = torch.ones(n_heads, head_size)
        heads = set(heads) - already_pruned_heads
        for head in heads:
            head = head - sum(1 if h < head else 0 for h in already_pruned_heads)
            mask[head] = 0
        mask = mask.view(-1).eq(1)
        index = torch.arange(len(mask))[mask].long()
        return mask, index

    def prune_linear_layer(layer: nn.Linear, index: torch.LongTensor, dim: int = 0) -> nn.Linear:
        index = index.to(layer.weight.device)
        W = layer.weight.index_select(dim, index).clone().detach()
        if layer.bias is not None:
            if dim == 1:
                b = layer.bias.clone().detach()
            else:
                b = layer.bias[index].clone().detach()
        new_size = list(layer.weight.size())
        new_size[dim] = len(index)
        new_layer = nn.Linear(new_size[1], new_size[0], bias=layer.bias is not None).to(layer.weight.device)
        new_layer.weight.requires_grad = False
        new_layer.weight.copy_(W.contiguous())
        new_layer.weight.requires_grad = True
        if layer.bias is not None:
            new_layer.bias.requires_grad = False
            new_layer.bias.copy_(b.contiguous())
            new_layer.bias.requires_grad = True
        return new_layer

    # Inject functions if missing
    if not hasattr(transformers.pytorch_utils, "find_pruneable_heads_and_indices"):
        transformers.pytorch_utils.find_pruneable_heads_and_indices = find_pruneable_heads_and_indices
    if not hasattr(transformers.pytorch_utils, "prune_linear_layer"):
        transformers.pytorch_utils.prune_linear_layer = prune_linear_layer
        
    print("Successfully patched transformers.pytorch_utils for RF-DETR compatibility.")

except Exception as e:
    print(f"Warning: Failed to apply transformers patch: {e}")
# --- END COMPATIBILITY PATCH ---

import cv2
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from PIL import Image
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from torchvision import models, transforms

try:
    import supervision as sv
    # Try importing the 2XLarge model; fallback to Large/Medium if not found in your version
    from rfdetr import RFDETRSeg2XLarge
except ImportError as e:
    print("Error importing rfdetr or supervision:", e)
    print("Please install with: pip install rfdetr supervision")
    raise

def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)


def load_model(device: str = "cpu"):
    print(f"Loading RF-DETR-Seg-2XLarge model on {device}...")
    # RF-DETR handles device placement internally, usually checking cuda availability
    model = RFDETRSeg2XLarge()
    return model


def get_resnet_embedder(device="cpu"):
    print("Loading ResNet50 embedder (ImageNet pretrained) ...")
    resnet = models.resnet50(pretrained=True)
    # remove final classification layer
    modules = list(resnet.children())[:-1]
    backbone = torch.nn.Sequential(*modules)
    backbone.eval()
    backbone.to(device)

    preprocess = transforms.Compose([
        transforms.ToPILImage(),
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])

    @torch.no_grad()
    def embed(img: np.ndarray):
        x = preprocess(img).unsqueeze(0).to(device)
        feat = backbone(x)  # shape: (1, 2048, 1, 1)
        feat = feat.reshape(feat.shape[0], -1)
        feat = feat.cpu().numpy()[0]
        # L2 normalize
        feat = feat / (np.linalg.norm(feat) + 1e-8)
        return feat

    return embed


def masks_to_components(mask: np.ndarray, area_min: int = 50):
    # mask: binary uint8 of shape (H, W)
    # return list of components: each is a dict with label mask and bbox
    num_labels, labels, stats, centroids = cv2.connectedComponentsWithStats(mask, connectivity=8)
    comps = []
    h, w = mask.shape
    for lbl in range(1, num_labels):
        area = stats[lbl, cv2.CC_STAT_AREA]
        if area < area_min:
            continue
        x = int(stats[lbl, cv2.CC_STAT_LEFT])
        y = int(stats[lbl, cv2.CC_STAT_TOP])
        ww = int(stats[lbl, cv2.CC_STAT_WIDTH])
        hh = int(stats[lbl, cv2.CC_STAT_HEIGHT])
        comp_mask = (labels == lbl).astype('uint8')
        comps.append({
            'mask': comp_mask,
            'bbox': (x, y, x + ww, y + hh),
            'area': int(area)
        })
    return comps


def extract_patch(img: np.ndarray, bbox, mask=None, pad=4):
    x1, y1, x2, y2 = bbox
    h, w = img.shape[:2]
    x1p = max(0, x1 - pad)
    y1p = max(0, y1 - pad)
    x2p = min(w, x2 + pad)
    y2p = min(h, y2 + pad)
    crop = img[y1p:y2p, x1p:x2p].copy()
    if mask is not None:
        m = mask[y1p:y2p, x1p:x2p]
        # apply alpha to background
        alpha = (m > 0).astype('uint8') * 255
        if crop.shape[2] == 3:
            crop = cv2.cvtColor(crop, cv2.COLOR_BGR2BGRA)
        # ensure alpha channel is set from mask (overwrite any existing alpha)
        crop[:, :, 3] = alpha
    # return crop and the padded bbox coordinates (x1p,y1p,x2p,y2p)
    return crop, (x1p, y1p, x2p, y2p)


def visualize_overlay(orig_img, patch_masks, clusters, out_path):
    # patch_masks: list of binary masks (same size as orig_img HxW)
    # clusters: list of cluster ids for each mask
    h, w = orig_img.shape[:2]
    overlay = orig_img.copy()
    cmap = plt.get_cmap('tab20')
    colors = [tuple(int(255 * c) for c in cmap(i % 20)[:3]) for i in range(20)]
    alpha = 0.5
    # create colored overlay
    canvas = overlay.copy()
    for i, (m, c) in enumerate(zip(patch_masks, clusters)):
        color = colors[c % len(colors)]
        colored = np.zeros_like(overlay, dtype=np.uint8)
        colored[:, :] = color
        mask3 = np.stack([m > 0] * 3, axis=-1)
        canvas = np.where(mask3, (canvas * (1 - alpha) + np.array(color) * alpha).astype(np.uint8), canvas)
    # blend
    blend = cv2.addWeighted(orig_img, 0.6, canvas, 0.4, 0)
    cv2.imwrite(str(out_path), cv2.cvtColor(blend, cv2.COLOR_RGB2BGR))


def draw_clustered_total_overlay(orig_img, masks, labels, parent_classes=None, out_path=None, names=None, alpha=0.5, seed=None):
    """
    Colors patches by Cluster ID.
    """
    img = orig_img.copy()
    h, w = img.shape[:2]
    
    # Generate a fixed palette for clusters (up to 30 distinct colors)
    np.random.seed(42)
    cluster_palette = [tuple(int(c) for c in np.random.randint(50, 255, size=3)) for _ in range(max(labels) + 1)]

    # 1. Draw the color fills first
    overlay = img.copy()
    for i, (m, lbl) in enumerate(zip(masks, labels)):
        if m.sum() == 0: continue
        
        color = cluster_palette[lbl] # Use cluster color
        mask_bool = (m > 0)
        
        # Apply color overlay
        overlay = np.where(
            np.stack([mask_bool] * 3, axis=-1),
            (overlay * (1 - alpha) + np.array(color) * alpha).astype(np.uint8),
            overlay
        )
    
    # Blend overlay back onto base image
    canvas = overlay

    # 2. Draw contours and Labels (Filtered)
    min_label_area = (h * w) * 0.005  

    for i, (m, lbl) in enumerate(zip(masks, labels)):
        area = int((m > 0).sum())
        if area == 0: continue

        # Use cluster color for border
        color = cluster_palette[lbl]
        border_color = tuple(max(0, c - 60) for c in color)

        # Find contours
        contours, _ = cv2.findContours(m, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(canvas, contours, -1, border_color, thickness=1)

        # SKIP LABELING if too small
        if area < min_label_area:
            continue

        # --- Label Logic ---
        name = f"Cluster {lbl}"
        if parent_classes is not None:
            pc = parent_classes[i]
            if pc != -1 and names is not None:
                try: 
                    cls_name = names[pc] 
                    name = f"{cls_name} (c{lbl})"
                except: pass
        
        label_text = f"{name} {area}px"

        # Find best place for label
        if contours:
            largest = max(contours, key=cv2.contourArea)
            x, y, rw, rh = cv2.boundingRect(largest)
            
            font_scale = max(0.4, min(0.8, rw / 200.0))
            ((tw, th), _) = cv2.getTextSize(label_text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 1)
            
            cx = x + (rw // 2) - (tw // 2)
            cy = y + (rh // 2) + (th // 2)
            cx = max(0, min(w - tw, cx))
            cy = max(th, min(h, cy))

            cv2.rectangle(canvas, (cx - 2, cy - th - 4), (cx + tw + 2, cy + 4), border_color, -1)
            cv2.putText(canvas, label_text, (cx, cy), cv2.FONT_HERSHEY_SIMPLEX, font_scale, (255, 255, 255), 1, cv2.LINE_AA)

    if out_path is not None:
        cv2.imwrite(str(out_path), cv2.cvtColor(canvas, cv2.COLOR_RGB2BGR))
    
    return canvas


def draw_instance_overlay_sv(detections, orig_img, out_path, stylize=False, title_text=None):
    """
    Uses Supervision to draw masks and boxes.
    """
    # Create annotators
    mask_annotator = sv.MaskAnnotator()
    box_annotator = sv.BoxAnnotator()
    label_annotator = sv.LabelAnnotator(text_scale=0.5, text_thickness=1)

    # Convert BGR to RGB if needed (Supervision expects image array)
    # orig_img is RGB in our run function, so we copy it.
    annotated_image = orig_img.copy()

    # Annotate
    annotated_image = mask_annotator.annotate(scene=annotated_image, detections=detections)
    annotated_image = box_annotator.annotate(scene=annotated_image, detections=detections)
    annotated_image = label_annotator.annotate(scene=annotated_image, detections=detections)

    # Optional Title
    h, w = annotated_image.shape[:2]
    if stylize:
        banner_h = max(40, int(h * 0.08))
        # Draw red banner at bottom
        cv2.rectangle(annotated_image, (0, h - banner_h), (w, h), (200, 30, 30), -1) 
        if title_text is None:
            title_text = "RF-DETR-XXL Detection + Segmentation"
        ((tw, th), _) = cv2.getTextSize(title_text, cv2.FONT_HERSHEY_SIMPLEX, 1.0, 2)
        cv2.putText(annotated_image, title_text, ((w - tw) // 2, h - banner_h // 2 + th // 2), 
                    cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 255, 255), 2, cv2.LINE_AA)

    # Save as BGR
    cv2.imwrite(str(out_path), cv2.cvtColor(annotated_image, cv2.COLOR_RGB2BGR))


def run(args):
    img_path = Path(args.image)
    assert img_path.exists(), f"Image not found: {img_path}"
    outroot = Path(args.output_dir) / img_path.stem
    ensure_dir(outroot)

    # Load image (OpenCV for processing, PIL for RF-DETR inference if needed)
    img_bgr = cv2.imread(str(img_path))
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    
    # RF-DETR expects PIL image or numpy array (RGB)
    pil_image = Image.fromarray(img_rgb)

    t_start = time.time()
    device = 'cuda' if torch.cuda.is_available() and not args.force_cpu else 'cpu' 
    
    # --- 1. Load RF-DETR Model ---
    model = load_model(device)

    print(f"Running segmentation (conf={args.conf_thres}) ...")
    # RF-DETR predict returns a Supervision Detections object directly
    detections = model.predict(pil_image, threshold=args.conf_thres)

    if len(detections) == 0:
        print("No results from model")
        return

    # --- 2. Draw Detection Overlay (using Supervision) ---
    try:
        draw_instance_overlay_sv(detections, img_rgb, outroot / 'detection_overlay.png', 
                                 stylize=args.stylize, title_text=args.title_text)
        print(f"Wrote detection overlay to {outroot / 'detection_overlay.png'}")
    except Exception as e:
        print("Failed to draw detection overlay:", e)
        import traceback
        traceback.print_exc()

    # --- 3. Extract Data from Detections ---
    # Supervision detections object has: .xyxy, .mask, .class_id, .confidence
    # masks will be boolean arrays (N, H, W)
    masks_bool = detections.mask
    boxes = detections.xyxy
    class_ids = detections.class_id
    
    # If no masks found (model run in detection-only mode?), fallback to box-masks
    if masks_bool is None:
        print("No masks found in detections (detection-only mode?). Creating box masks.")
        h, w = img_rgb.shape[:2]
        masks_bool = np.zeros((len(boxes), h, w), dtype=bool)
        for i, (x1, y1, x2, y2) in enumerate(boxes):
            x1, y1, x2, y2 = map(int, [x1, y1, x2, y2])
            masks_bool[i, y1:y2, x1:x2] = True
    
    # Convert to list of uint8 masks for compatibility with rest of script
    masks = [(m.astype('uint8') * 1) for m in masks_bool] # 0/1 masks

    print(f"Found {len(masks)} top-level masks")

    # Map classes
    # If RF-DETR model has class names, we can use them. 
    # Usually stored in model.classes (dict or list) if available, but differs by wrapper.
    # We'll rely on class_ids.
    
    # Collect components
    all_comps = []
    for mi, m in enumerate(masks):
        # We pass 0/1 mask. masks_to_components expects 0/1 or 0/255 (it handles both if binary)
        comps = masks_to_components(m, area_min=0)
        for c in comps:
            c['parent_mask_idx'] = mi
            all_comps.append(c)

    if len(all_comps) == 0:
        print("No components found in masks.")
        return

    # --- 4. Area Analysis (Same as before) ---
    areas = np.array([c['area'] for c in all_comps])
    ensure_dir(outroot)
    try:
        plt.figure(figsize=(6, 4))
        plt.hist(areas, bins=args.hist_bins, color='C0', alpha=0.9)
        plt.xlabel('Component area (pixels)')
        plt.ylabel('Count')
        plt.title('Component area distribution')
        plt.tight_layout()
        plt.savefig(outroot / 'area_hist.png')
        plt.close()
    except Exception: pass

    suggested_area = int(max(1, np.percentile(areas, args.area_quantile * 100)))
    if args.auto_area:
        area_min = suggested_area
        print(f"Auto-area enabled: using area_min={area_min}")
    else:
        area_min = args.area_min
        print(f"Using area_min={area_min}")

    comp_list = [c for c in all_comps if c['area'] >= area_min]
    print(f"Kept {len(comp_list)} components >= area {area_min}")

    if len(comp_list) == 0:
        return

    # --- 5. Clustering (Same as before) ---
    embed = get_resnet_embedder(device=device)

    patches = []
    for i, comp in enumerate(comp_list):
        mask = comp['mask']
        bbox = comp['bbox']
        crop, bbox_padded = extract_patch(img_rgb, bbox, mask=mask, pad=args.pad)
        # convert to BGR for embedding if embedder expects standard CV2 logic, 
        # but our embedder uses PIL transform which handles RGB. 
        # However, the script previously converted crop (RGB/RGBA) -> BGR for embedding?
        # Actually ResNet pretrained expects RGB. Our previous script did cvtColor BGRA->BGR.
        # Since crop here comes from img_rgb, it is RGB or RGBA.
        # We just need to ensure 3 channels for the embedder.
        if crop.shape[-1] == 4:
            crop_embed = crop[:, :, :3]
        else:
            crop_embed = crop
            
        emb = embed(crop_embed)
        patches.append({
            'crop': crop, 
            'emb': emb, 
            'bbox': bbox, 
            'bbox_padded': bbox_padded, 
            'area': comp['area'], 
            'parent': comp['parent_mask_idx'], 
            'mask_full': comp['mask']
        })

    print(f"Extracted {len(patches)} patches; computing embeddings matrix ...")
    X = np.stack([p['emb'] for p in patches], axis=0)
    n_samples = X.shape[0]
    
    if n_samples < 2:
        labels = np.zeros(n_samples, dtype=int)
        k = 1
    else:
        if args.auto_k:
            k_max = min(args.k_max, n_samples)
            k_range = range(2, max(2, k_max) + 1)
            sil_scores = []
            print(f"Auto-k: evaluating k in {list(k_range)} ...")
            for kk in k_range:
                km = KMeans(n_clusters=kk, random_state=0).fit(X)
                try:
                    ss = silhouette_score(X, km.labels_)
                except: ss = -1.0
                sil_scores.append(ss)
            best_idx = int(np.argmax(sil_scores))
            k = list(k_range)[best_idx]
            print(f"Auto-k selected k={k}")
        else:
            k = min(args.k, n_samples)
        kmeans = KMeans(n_clusters=k, random_state=0).fit(X)
        labels = kmeans.labels_

    # --- 6. Save Outputs ---
    rows = []
    patch_masks_rgb = []
    for idx, (p, lbl) in enumerate(zip(patches, labels)):
        fname = outroot / f"patch_{idx:04d}_c{lbl}.png"
        crop = p['crop']
        # Convert RGB(A) -> BGR(A) for cv2.imwrite
        if crop.shape[-1] == 4:
            out_crop = cv2.cvtColor(crop, cv2.COLOR_RGBA2BGRA)
        else:
            out_crop = cv2.cvtColor(crop, cv2.COLOR_RGB2BGR)
        cv2.imwrite(str(fname), out_crop)
        
        x1, y1, x2, y2 = p['bbox']
        rows.append({
            'patch_id': idx, 
            'file': str(fname.name), 
            'cluster': int(lbl), 
            'area': int(p['area']), 
            'bbox': f"{x1},{y1},{x2},{y2}", 
            'parent_mask': int(p['parent'])
        })
        mask_full = (p['mask_full'] > 0).astype('uint8') * 255
        patch_masks_rgb.append(mask_full)

    df = pd.DataFrame(rows)
    df.to_csv(outroot / 'patches.csv', index=False)

    # Final Visualization
    try:
        masks_bool_list = [(m > 0).astype('uint8') for m in patch_masks_rgb]
        visualize_overlay(img_rgb, masks_bool_list, labels, outroot / 'overlay.png')
        print(f"Wrote overlay to {outroot / 'overlay.png'}")

        # Total clustered overlay
        try:
            # We map parent mask indices back to class IDs
            parent_classes = [class_ids[p['parent']] if p['parent'] < len(class_ids) else -1 for p in patches]
            
            # Note: We need a class-id-to-name mapping. 
            # RF-DETR models often use standard COCO classes if pretrained.
            # supervision has standard COCO classes we can try to use as fallback.
            # But the model object might not expose them simply.
            # We will try to rely on the user knowing classes or just use IDs.
            # If supervision Detections object had 'class_name', we'd use it, but it usually doesn't by default.
            
            draw_clustered_total_overlay(
                img_rgb, masks_bool_list, labels, 
                parent_classes=parent_classes, 
                out_path=outroot / 'overlay_total.jpg', 
                names=None, # pass dict if you have custom classes
                alpha=0.6
            )
            print(f"Wrote total clustered overlay to {outroot / 'overlay_total.jpg'}")
        except Exception as e:
            print("Failed to create total clustered overlay:", e)
            import traceback
            traceback.print_exc()

    except Exception as e:
        print("Failed to create overlay:", e)

    elapsed = time.time() - t_start
    print(f"Total processing time: {elapsed:.2f} s")
    print("Done.")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--image', type=str, default='food.jpg', help='Path to input image')
    parser.add_argument('--k', type=int, default=6, help='Number of clusters for patch grouping')
    parser.add_argument('--area-min', type=int, default=100, help='Minimum connected component area to keep')
    parser.add_argument('--pad', type=int, default=6, help='Crop padding in pixels')
    parser.add_argument('--conf-thres', type=float, default=0.25, help='Detection confidence threshold')
    parser.add_argument('--imgsz', type=int, default=1280, help='Input image size (not strictly used by all RF-DETR wrappers but kept for compat)')
    parser.add_argument('--output-dir', type=str, default='results', help='Results directory')
    parser.add_argument('--force-cpu', action='store_true', help='Force CPU even when CUDA is available')

    # Auto-selection options
    parser.add_argument('--auto-area', action='store_true', help='Automatically suggest area-min')
    parser.add_argument('--area-quantile', type=float, default=0.05, help='Quantile for auto-area (0-1)')
    parser.add_argument('--hist-bins', type=int, default=50, help='Histogram bins')

    parser.add_argument('--auto-k', action='store_true', help='Automatically choose k')
    parser.add_argument('--k-max', type=int, default=10, help='Max k for auto-k')

    parser.add_argument('--stylize', action='store_true', help='Add a stylized bottom banner')
    parser.add_argument('--title-text', type=str, default=None, help='Custom title text')

    args = parser.parse_args()
    run(args)