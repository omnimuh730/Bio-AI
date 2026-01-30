YOLOv8x-seg material patch extractor and clustering 🔧

## Goal

Use YOLOv8x-seg to get instance masks from a food image, split masks into small connected components (material "pieces"), extract patches, compute embeddings (ResNet50), and cluster them to group similar materials.

## Quick start

1. Create a virtual env and install:

    python -m venv .venv
    .venv\Scripts\activate
    pip install -r requirements.txt

2. Place your image next to `main.py`, name it `food.jpg` (or pass --image path).

3. Run:

    python main.py --image food.jpg --k 6 --area-min 120

## Outputs

- results/<image-stem>/patch\_\*.png — extracted patches
- results/<image-stem>/patches.csv — metadata (cluster, bbox, area)
- results/<image-stem>/overlay.png — visualization overlay

## Notes & next steps

- This is a pipeline scaffold. For real fine-grained "material" classification you will likely need to train a custom classifier on labelled patches. Replace the KMeans step in `main.py` with your classifier model inference.
- If YOLOv8x-seg fails to detect small pieces, try lowering `--conf-thres` and `--area-min`.
- If you have a GPU, the script will use CUDA automatically unless you pass `--force-cpu`.

"""}
