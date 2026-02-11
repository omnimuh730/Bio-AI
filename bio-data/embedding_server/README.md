# Bio Data Embedding Server

Simple FastAPI service that creates multi-vector embeddings for products and returns them to the Node backend.

## Quick start

1. Create a virtual environment and install deps:
    - `python -m venv .venv`
    - `.venv\Scripts\activate`
    - `pip install -r requirements.txt`
2. Run:
    - `uvicorn app.main:app --host 0.0.0.0 --port 7001`

## Config

- `EMBEDDING_MODEL` (default: `intfloat/e5-large-v2`)
- `EMBEDDING_PREFIX` (default: `passage: `)
