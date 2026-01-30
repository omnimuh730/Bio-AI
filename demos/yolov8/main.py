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
from sklearn.metrics import silhouette_score
from torchvision import models, transforms

try:
	from ultralytics import YOLO
	from ultralytics.utils.ops import scale_masks
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


def draw_clustered_total_overlay(orig_img, masks, labels, parent_classes=None, out_path=None, names=None, alpha=0.5, seed=None):
	"""
	Improved visualization:
	1. Colors patches by Cluster ID (not random per patch).
	2. Only draws text labels if the patch area is significant.
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
	# Only label areas larger than 0.5% of the total image pixels to reduce clutter
	min_label_area = (h * w) * 0.005  

	for i, (m, lbl) in enumerate(zip(masks, labels)):
		area = int((m > 0).sum())
		if area == 0: continue

		# Use cluster color for border
		color = cluster_palette[lbl]
		border_color = tuple(max(0, c - 60) for c in color) # Darker version of cluster color

		# Find contours
		contours, _ = cv2.findContours(m, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
		cv2.drawContours(canvas, contours, -1, border_color, thickness=1)

		# SKIP LABELING if too small
		if area < min_label_area:
			continue

		# --- Label Logic ---
		# Determine Name
		name = f"Cluster {lbl}"
		if parent_classes is not None:
			pc = parent_classes[i]
			if pc != -1 and names is not None:
				# Try to get class name
				try: 
					cls_name = names[pc] 
					name = f"{cls_name} (c{lbl})"
				except: pass
		
		label_text = f"{name} {area}px"

		# Find best place for label
		if contours:
			largest = max(contours, key=cv2.contourArea)
			x, y, rw, rh = cv2.boundingRect(largest)
			
			# adaptive font scale based on patch width, not image width
			font_scale = max(0.4, min(0.8, rw / 200.0))
			
			((tw, th), _) = cv2.getTextSize(label_text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 1)
			
			# Center label in bbox
			cx = x + (rw // 2) - (tw // 2)
			cy = y + (rh // 2) + (th // 2)
			
			# Clamp to image
			cx = max(0, min(w - tw, cx))
			cy = max(th, min(h, cy))

			# Draw label background
			cv2.rectangle(canvas, (cx - 2, cy - th - 4), (cx + tw + 2, cy + 4), border_color, -1)
			cv2.putText(canvas, label_text, (cx, cy), cv2.FONT_HERSHEY_SIMPLEX, font_scale, (255, 255, 255), 1, cv2.LINE_AA)

	if out_path is not None:
		cv2.imwrite(str(out_path), cv2.cvtColor(canvas, cv2.COLOR_RGB2BGR))
	
	return canvas


def draw_instance_overlay(res, orig_img, out_path, masks=None, names=None, stylize=False, title_text=None):
	"""Draw instance masks, bounding boxes, and labels from a YOLOv8 result.
	- res: a single result object from ultralytics (res = results[0])
	- orig_img: RGB image np.ndarray
	- masks: Optional list of binary masks (scaled to orig_img). If None, tries to extract from res (may fail if not scaled).
	- names: list or dict mapping class_id->name (model.names)
	- stylize: if True, add a red bottom banner with title text
	"""
	img = orig_img.copy()
	h, w = img.shape[:2]
	# convert to BGR for OpenCV drawing
	canvas = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
	cmap = plt.get_cmap('tab20')

	# extract masks if NOT provided
	if masks is None:
		masks = []
		if hasattr(res, 'masks') and res.masks is not None:
			if hasattr(res.masks, 'data'):
				md = res.masks.data.cpu().numpy()
				for i in range(md.shape[0]):
					masks.append((md[i] > 0.5).astype('uint8'))
			else:
				try:
					md = np.array(res.masks)
					for m in md:
						masks.append((m > 0.5).astype('uint8'))
				except Exception:
					masks = []

	# boxes and confidences
	boxes = []
	confs = []
	classes = []
	if hasattr(res, 'boxes') and res.boxes is not None:
		data = res.boxes.data.cpu().numpy()
		for row in data:
			x1, y1, x2, y2 = map(int, row[:4])
			conf = float(row[4]) if row.shape[0] > 4 else 0.0
			cls = int(row[5]) if row.shape[0] > 5 else 0
			boxes.append((x1, y1, x2, y2))
			confs.append(conf)
			classes.append(cls)

	# helper to resolve class name
	def _get_name(cls_id):
		if names is None:
			return str(cls_id)
		try:
			# list-like
			return names[cls_id]
		except Exception:
			try:
				return names.get(cls_id, str(cls_id))
			except Exception:
				return str(cls_id)

	# for each box, try to find the best overlapping mask (if masks exist)
	for i, box in enumerate(boxes):
		x1, y1, x2, y2 = box
		color = tuple(int(255 * c) for c in cmap(i % 20)[:3])
		matched_mask = None
		if len(masks) > 0:
			if len(masks) == len(boxes):
				matched_mask = masks[i]
			else:
				# find mask with largest overlap area inside box
				best_a = 0
				best_m = None
				for m in masks:
					# compute overlap
					yy1 = max(0, y1)
					yy2 = min(h, y2)
					xx1 = max(0, x1)
					xx2 = min(w, x2)
					if yy2 <= yy1 or xx2 <= xx1:
						continue
					sub = m[yy1:yy2, xx1:xx2]
					a = int(sub.sum())
					if a > best_a:
						best_a = a
						best_m = m
				if best_a > 0:
					matched_mask = best_m
		# draw mask fill if available
		if matched_mask is not None:
			m = matched_mask
			mask_bool = (m > 0)
			colored = np.zeros_like(canvas, dtype=np.uint8)
			colored[:, :] = color
			alpha = 0.45
			mask3 = np.stack([mask_bool] * 3, axis=-1)
			canvas = np.where(mask3, (canvas * (1 - alpha) + np.array(color) * alpha).astype(np.uint8), canvas)
		# draw box
		cv2.rectangle(canvas, (x1, y1), (x2, y2), color, 2)
		# label
		cls_id = classes[i] if i < len(classes) else -1
		conf = confs[i] if i < len(confs) else 0.0
		name = _get_name(cls_id)
		label = f"{name} {conf:.2f}"
		((tw, th), _) = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.7, 2)
		# background rectangle for label (slightly above box)
		y0 = max(0, y1 - th - 6)
		cv2.rectangle(canvas, (x1, y0), (x1 + tw + 8, y0 + th + 6), color, -1)
		cv2.putText(canvas, label, (x1 + 4, y0 + th + 1), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2, cv2.LINE_AA)

	# if there are masks with no boxes, draw them as well
	if len(masks) > len(boxes):
		start = len(boxes)
		for i in range(start, len(masks)):
			color = tuple(int(255 * c) for c in cmap(i % 20)[:3])
			m = masks[i]
			mask_bool = (m > 0)
			canvas = np.where(np.stack([mask_bool] * 3, axis=-1), (canvas * 0.55 + np.array(color) * 0.45).astype(np.uint8), canvas)

	# optional stylized bottom banner
	if stylize:
		banner_h = max(40, int(h * 0.08))
		cv2.rectangle(canvas, (0, h - banner_h), (w, h), (200, 30, 30), -1)  # red banner
		if title_text is None:
			title_text = "YOLOv8 Object Detection + Instance Segmentation"
		((tw, th), _) = cv2.getTextSize(title_text, cv2.FONT_HERSHEY_SIMPLEX, 1.0, 2)
		cv2.putText(canvas, title_text, ((w - tw) // 2, h - banner_h // 2 + th // 2), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 255, 255), 2, cv2.LINE_AA)

	cv2.imwrite(str(out_path), canvas)


def run(args):
	img_path = Path(args.image)
	assert img_path.exists(), f"Image not found: {img_path}"
	outroot = Path(args.output_dir) / img_path.stem
	ensure_dir(outroot)
	img_bgr = cv2.imread(str(img_path))
	img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)

	t_start = time.time()

	device = 'cuda' if torch.cuda.is_available() and not args.force_cpu else 'cpu' 

	model = load_model(device)

	print(f"Running segmentation (conf={args.conf_thres}) ...")
	results = model.predict(source=str(img_path), imgsz=args.imgsz, conf=args.conf_thres, verbose=False)

	if len(results) == 0:
		print("No results from model")
		return
	res = results[0]

	# --- 1. Extract and Scale Masks Correctly ---
	masks = []
	if hasattr(res, 'masks') and res.masks is not None:
		if hasattr(res.masks, 'data'):
			md_tensor = res.masks.data
			
			# FIX: scale_masks expects (N, 1, H, W) or (N, H, W) depending on version.
			# If we get (N, H, W), we unsqueeze to (N, 1, H, W) to be safe for unpacking.
			if md_tensor.ndim == 3:
				md_tensor = md_tensor.unsqueeze(1) # (N, 1, H, W)

			# Scale masks from inference size (padded) back to original image size
			md_tensor = scale_masks(md_tensor, res.orig_shape)
			
			# Squeeze back to (N, H, W)
			md_tensor = md_tensor.squeeze(1)
			
			md = md_tensor.cpu().numpy()
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

	# fallback: use boxes if no masks found
	if len(masks) == 0 and hasattr(res, 'boxes') and res.boxes is not None:
		print("No masks found, using bounding boxes as coarse masks.")
		for box in res.boxes.data.cpu().numpy():
			x1, y1, x2, y2, conf, cls = box[:6]
			mask = np.zeros(img.shape[:2], dtype='uint8')
			x1i, y1i, x2i, y2i = map(int, [x1, y1, x2, y2])
			mask[y1i:y2i, x1i:x2i] = 1
			masks.append(mask)

	print(f"Found {len(masks)} top-level masks / boxes")

	# --- 2. Draw Detection Overlay (using Scaled Masks) ---
	try:
		draw_instance_overlay(res, img, outroot / 'detection_overlay.png', 
							  masks=masks,  # Pass the scaled masks here
							  names=getattr(model, 'names', None), 
							  stylize=args.stylize, 
							  title_text=args.title_text)
		print(f"Wrote detection overlay to {outroot / 'detection_overlay.png'}")
	except Exception as e:
		print("Failed to draw detection overlay:", e)
		import traceback
		traceback.print_exc()

	# Attempt to associate each top-level mask with a detection class id (if available)
	mask_classes = [-1] * len(masks)
	if hasattr(res, 'boxes') and res.boxes is not None:
		box_data = res.boxes.data.cpu().numpy()
		# classes may be available in column 5
		box_classes = [int(row[5]) if row.shape[0] > 5 else -1 for row in box_data]
		# if lengths match, assume 1:1 mapping
		if len(box_classes) == len(masks):
			mask_classes = box_classes
		else:
			# match by overlap between mask and each box
			h_img, w_img = img.shape[:2]
			for mi, m in enumerate(masks):
				best_cls = -1
				best_area = 0
				for bi, row in enumerate(box_data):
					x1, y1, x2, y2 = map(int, row[:4])
					yy1 = max(0, y1); yy2 = min(h_img, y2)
					xx1 = max(0, x1); xx2 = min(w_img, x2)
					if yy2 <= yy1 or xx2 <= xx1:
						continue
					sub = m[yy1:yy2, xx1:xx2]
					a = int(sub.sum())
					if a > best_area:
						best_area = a
						best_cls = int(row[5]) if row.shape[0] > 5 else -1
				mask_classes[mi] = best_cls

	# collect all components (no area filtering yet) so we can compute area distribution
	all_comps = []
	for mi, m in enumerate(masks):
		comps = masks_to_components(m.astype('uint8'), area_min=0)
		# print(f"Mask {mi}: {len(comps)} components (no area filter)")
		for c in comps:
			c['parent_mask_idx'] = mi
			all_comps.append(c)

	if len(all_comps) == 0:
		print("No components found in masks.")
		return

	# analyze areas and optionally auto-select area threshold
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
		print(f"Wrote area histogram to {outroot / 'area_hist.png'}")
	except Exception as e:
		print("Failed to write area histogram:", e)

	suggested_area = int(max(1, np.percentile(areas, args.area_quantile * 100)))
	print(f"Area stats: min={areas.min()}, median={np.median(areas)}, max={areas.max()}, suggested area (quantile {args.area_quantile})={suggested_area}")

	if args.auto_area:
		area_min = suggested_area
		print(f"Auto-area enabled: using area_min={area_min}")
	else:
		area_min = args.area_min
		print(f"Using area_min={area_min}")

	comp_list = [c for c in all_comps if c['area'] >= area_min]
	print(f"Kept {len(comp_list)} components >= area {area_min}")

	if len(comp_list) == 0:
		print("No components left after applying area_min. Try decreasing --area-min or use --auto-area.")
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
		patches.append({'crop': crop, 'emb': emb, 'bbox': bbox, 'bbox_padded': bbox_padded, 'area': comp['area'], 'parent': comp['parent_mask_idx'], 'mask_full': comp['mask']})

	print(f"Extracted {len(patches)} patches; computing embeddings matrix ...")
	X = np.stack([p['emb'] for p in patches], axis=0)
	n_samples = X.shape[0]
	if n_samples < 2:
		print("Not enough patches for clustering (need >=2). Assigning single cluster 0 to all patches.")
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
				except Exception:
					ss = -1.0
				sil_scores.append(ss)
			best_idx = int(np.argmax(sil_scores))
			best_k = list(k_range)[best_idx]
			k = best_k
			print(f"Auto-k selected k={k} (best silhouette={sil_scores[best_idx]:.4f})")
			try:
				plt.figure(figsize=(6, 4))
				plt.plot(list(k_range), sil_scores, marker='o', label='silhouette')
				plt.xlabel('k')
				plt.ylabel('silhouette score')
				plt.title('Silhouette vs k')
				plt.grid(True)
				plt.tight_layout()
				plt.savefig(outroot / 'silhouette.png')
				plt.close()
				print(f"Wrote silhouette plot to {outroot / 'silhouette.png'}")
			except Exception as e:
				print("Failed to write silhouette plot:", e)
		else:
			k = min(args.k, n_samples)
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
		# use original full-size component mask to avoid any spatial shift
		mask_full = (p['mask_full'] > 0).astype('uint8') * 255
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

		# also produce a single total colored overlay showing clusters, borders and labels
		try:
			parent_classes = [mask_classes[p['parent']] if (p.get('parent') is not None and p['parent'] < len(mask_classes)) else -1 for p in patches]
			draw_clustered_total_overlay(img_rgb, masks_bool, labels, parent_classes=parent_classes, out_path=outroot / 'overlay_total.jpg', names=getattr(model, 'names', None), alpha=0.6, seed=None)
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
	parser.add_argument('--conf-thres', type=float, default=0.25, help='YOLO detection confidence threshold')
	parser.add_argument('--imgsz', type=int, default=1280, help='YOLO input image size')
	parser.add_argument('--output-dir', type=str, default='results', help='Results directory')
	parser.add_argument('--force-cpu', action='store_true', help='Force CPU even when CUDA is available')

	# Auto-selection options
	parser.add_argument('--auto-area', action='store_true', help='Automatically suggest and use area-min based on component area quantile')
	parser.add_argument('--area-quantile', type=float, default=0.05, help='Quantile used to suggest area-min when --auto-area is used (0-1)')
	parser.add_argument('--hist-bins', type=int, default=50, help='Number of bins for the area histogram')

	parser.add_argument('--auto-k', action='store_true', help='Automatically choose k with silhouette score')
	parser.add_argument('--k-max', type=int, default=10, help='Maximum k to consider when using --auto-k')

	parser.add_argument('--stylize', action='store_true', help='Add a stylized bottom banner and title to the detection overlay')
	parser.add_argument('--title-text', type=str, default=None, help='Custom title text for stylized overlay')

	args = parser.parse_args()
	run(args)