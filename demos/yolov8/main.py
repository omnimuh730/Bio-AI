"""
YOLOv8x-seg based material-level patch extraction and clustering

Usage:
    python main.py --image food.jpg --k 6 --area-min 120 --conf-thres 0.25

Outputs are written to ./results/<image-stem>/ with:
 - patched crops saved as PNG
 - overlay visualization `overlay.png`
 - `patches.csv` describing each patch and its cluster

Notes:
 - Requires `ultralytics`, `torch`, `torchvision`, `opencv-python`, `scikit-learn`, `scikit-image`, `numpy`, `matplotlib`, `pandas`.
 - If you have a custom classifier, replace the clustering step with your classifier inference.
"""

import argparse
import os
import sys
import time
from pathlib import Path

import cv2
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import torch
from sklearn.cluster import KMeans
from torchvision import models, transforms

try:
    from ultralytics import YOLO
except Exception as e:
    print("Error importing ultralytics YOLO:", e)
    print("Please install with: pip install ultralytics")
    raise


def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)


def load_model(device: str = "cpu"):
    # Try to use the official yolov8x-seg weights name (will download if needed)
    print(f"Loading YOLOv8x-seg model on {device}...")
    model = YOLO("yolov8x-seg.pt")
    if device == "cpu":
        model.to('cpu')
    else:
        model.to('cuda')
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


def run(args):
    img_path = Path(args.image)
    assert img_path.exists(), f"Image not found: {img_path}"
    outroot = Path(args.output_dir) / img_path.stem
    ensure_dir(outroot)
    img_bgr = cv2.imread(str(img_path))
    img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)

    device = 'cuda' if torch.cuda.is_available() and not args.force_cpu else 'cpu'

    model = load_model(device)

    print(f"Running segmentation (conf={args.conf_thres}) ...")
    results = model.predict(source=str(img_path), imgsz=args.imgsz, conf=args.conf_thres, verbose=False)

    if len(results) == 0:
        print("No results from model")
        return
    res = results[0]

    # Get masks
    masks = []
    if hasattr(res, 'masks') and res.masks is not None:
        # ultralytics Mask type may have .data or .masks
        if hasattr(res.masks, 'data'):
            md = res.masks.data  # tensor (n, h, w)
            md = md.cpu().numpy()
            for i in range(md.shape[0]):
                masks.append((md[i] > 0.5).astype('uint8'))
        elif isinstance(res.masks, (list, tuple, np.ndarray)):
            for m in res.masks:
                masks.append((m > 0.5).astype('uint8'))
        else:
            try:
                md = np.array(res.masks)
                for m in md:
                    masks.append((m > 0.5).astype('uint8'))
            except Exception:
                print("Could not parse masks from result; falling back to boxes.")
    # fallback: use boxes
    if len(masks) == 0 and hasattr(res, 'boxes') and res.boxes is not None:
        print("No masks found, using bounding boxes as coarse masks.")
        for box in res.boxes.data.cpu().numpy():
            x1, y1, x2, y2, conf, cls = box[:6]
            mask = np.zeros(img.shape[:2], dtype='uint8')
            x1i, y1i, x2i, y2i = map(int, [x1, y1, x2, y2])
            mask[y1i:y2i, x1i:x2i] = 1
            masks.append(mask)

    print(f"Found {len(masks)} top-level masks / boxes")

    # break masks into small components
    area_min = args.area_min
    comp_list = []
    for mi, m in enumerate(masks):
        comps = masks_to_components(m.astype('uint8'), area_min=area_min)
        print(f"Mask {mi}: {len(comps)} components >= area {area_min}")
        for c in comps:
            c['parent_mask_idx'] = mi
            comp_list.append(c)

    if len(comp_list) == 0:
        print("No components found with the given area_min. Try decreasing --area-min.")
        return

    # prepare embedder
    embed = get_resnet_embedder(device=device)

    # extract patches and embeddings
    patches = []
    for i, comp in enumerate(comp_list):
        mask = comp['mask']
        bbox = comp['bbox']
        crop, bbox_padded = extract_patch(img, bbox, mask=mask, pad=args.pad)
        # convert BGRA->BGR if present
        if crop.shape[-1] == 4:
            crop_for_embed = cv2.cvtColor(crop, cv2.COLOR_BGRA2BGR)
        else:
            crop_for_embed = crop
        emb = embed(crop_for_embed)
        patches.append({'crop': crop, 'emb': emb, 'bbox': bbox, 'bbox_padded': bbox_padded, 'area': comp['area'], 'parent': comp['parent_mask_idx']})

    print(f"Extracted {len(patches)} patches; running KMeans (k={args.k}) ...")
    X = np.stack([p['emb'] for p in patches], axis=0)
    k = min(args.k, len(patches))
    kmeans = KMeans(n_clusters=k, random_state=0).fit(X)
    labels = kmeans.labels_

    # save patches and CSV
    rows = []
    patch_masks_rgb = []
    for idx, (p, lbl) in enumerate(zip(patches, labels)):
        fname = outroot / f"patch_{idx:04d}_c{lbl}.png"
        # save crop (BGR) convert to bgr for cv2
        crop = p['crop']
        # ensure saved as PNG with alpha if present
        if crop.shape[-1] == 4:
            cv2.imwrite(str(fname), cv2.cvtColor(crop, cv2.COLOR_RGBA2BGRA))
        else:
            cv2.imwrite(str(fname), cv2.cvtColor(crop, cv2.COLOR_RGB2BGR))
        x1, y1, x2, y2 = p['bbox']
        rows.append({'patch_id': idx, 'file': str(fname.name), 'cluster': int(lbl), 'area': int(p['area']), 'bbox': f"{x1},{y1},{x2},{y2}", 'parent_mask': int(p['parent'])})
        # build a mask to draw overlay using the padded bbox so the assignment matches crop size
        mask_full = np.zeros(img.shape[:2], dtype='uint8')
        x1p, y1p, x2p, y2p = p.get('bbox_padded', p['bbox'])
        if p['crop'].shape[-1] == 4:
            mask_full[y1p:y2p, x1p:x2p] = (p['crop'][:, :, 3] > 0).astype('uint8') * 255
        else:
            mask_full[y1p:y2p, x1p:x2p] = (p['crop'][:, :, 0] > 0).astype('uint8') * 255
        patch_masks_rgb.append(mask_full)

    df = pd.DataFrame(rows)
    df.to_csv(outroot / 'patches.csv', index=False)

    # visualization
    try:
        # convert mask arrays to boolean masks for overlay
        masks_bool = [(m > 0).astype('uint8') for m in patch_masks_rgb]
        img_rgb = img.copy()
        visualize_overlay(img_rgb, masks_bool, labels, outroot / 'overlay.png')
        print(f"Wrote overlay to {outroot / 'overlay.png'} and patches to {outroot}")
    except Exception as e:
        print("Failed to create overlay:", e)

    print("Done.")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--image', type=str, default='food.jpg', help='Path to input image')
    parser.add_argument('--k', type=int, default=6, help='Number of clusters for patch grouping')
    parser.add_argument('--area-min', type=int, default=100, help='Minimum connected component area to keep')
    parser.add_argument('--pad', type=int, default=6, help='Crop padding in pixels')
    parser.add_argument('--conf-thres', type=float, default=0.25, help='YOLO detection confidence threshold')
    parser.add_argument('--imgsz', type=int, default=1280, help='YOLO input image size')
    parser.add_argument('--output-dir', type=str, default='results', help='Results directory')
    parser.add_argument('--force-cpu', action='store_true', help='Force CPU even when CUDA is available')
    args = parser.parse_args()
    run(args)
