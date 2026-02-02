# FatSecret Integration Architecture

## Overview

The Bio AI application now uses FatSecret Platform API for food recognition, barcode lookup, and search functionality through a proper BFF (Backend for Frontend) architecture.

## Architecture Flow

```
Flutter App (bio_ai)
    ↓
FatSecretService (calls backend)
    ↓
bio_ai_server (BFF)
    ↓
FatSecret Platform API
```

## Backend (bio_ai_server)

### Configuration

- **File**: `app/config.py`
- **Environment Variables** (from `.env`):
    - `FATSECRET_CLIENT_ID` - FatSecret OAuth client ID
    - `FATSECRET_CLIENT_SECRET` - FatSecret OAuth client secret
    - `DATABASE_URL` - Database connection string
    - `UPLOAD_DIR` - Directory for uploaded images
    - `DEBUG` - Debug mode flag

### API Endpoints (`/api/vision/*`)

1. **POST /api/vision/search**
    - Search for food items by text query
    - Body: `{"query": string, "max_results": int}`

2. **POST /api/vision/barcode**
    - Look up food by barcode (UPC-A/GTIN-13)
    - Body: `{"barcode": string, "region": string}`

3. **POST /api/vision/recognize**
    - Recognize food in uploaded image
    - Body: multipart/form-data with `file`

4. **POST /api/vision/upload**
    - Upload image and get recognition results
    - Body: multipart/form-data with `file`

5. **GET /api/vision/autocomplete?q={query}**
    - Get autocomplete suggestions

6. **GET /api/vision/health**
    - Check API health and connectivity

### Security

- API credentials stored in `.env` file (not in code)
- `.env.example` provided as template
- OAuth token caching for efficiency

## Frontend (bio_ai Flutter)

### Service Layer

- **File**: `lib/core/platform_services/fatsecret/fatsecret_service.dart`
- **Provider**: `fatSecretServiceProvider` in `lib/app/di/injectors.dart`
- **Base URL**: Points to `$backendBaseUrl/api/vision`

### Features Implemented

#### 1. Photo Capture & Recognition

- Capture photo from camera
- Upload to backend for FatSecret image recognition
- Parse and display detected food items
- Location: `capture_screen.dart` → `_captureAndUpload()`

#### 2. Barcode Scanning

- Real-time barcode scanning using `mobile_scanner`
- Automatic lookup via FatSecret API
- Support for UPC-A and GTIN-13 formats
- Location: `capture_screen.dart` → `_handleBarcodeDetected()`
- UI: `capture_barcode_overlay.dart` with live scanner view

#### 3. Food Search

- Text-based food search
- Debounced API calls (1 second delay)
- Local + remote search fallback
- Location: `capture_screen.dart` → `_filterSearch()`

### Data Flow Example

#### Barcode Scanning:

1. User toggles barcode mode
2. `MobileScanner` widget activates
3. Barcode detected → `_handleBarcodeDetected()`
4. Flutter calls `fatSecretService.lookupBarcode()`
5. Service POSTs to `/api/vision/barcode`
6. Backend calls FatSecret API
7. Result parsed and displayed in overlay

#### Photo Recognition:

1. User taps shutter button
2. Camera captures photo → `_captureAndUpload()`
3. Flutter calls `fatSecretService.uploadAndRecognize()`
4. Service POSTs to `/api/vision/upload`
5. Backend processes image and calls FatSecret Recognition API
6. Results returned and food items added to meal

## Setup Instructions

### Backend Setup

1. Navigate to `bio_ai_server/`
2. Copy `.env.example` to `.env`
3. Add your FatSecret credentials to `.env`:
    ```
    FATSECRET_CLIENT_ID=your_client_id
    FATSECRET_CLIENT_SECRET=your_client_secret
    ```
4. Install dependencies: `pip install -r requirements.txt`
5. Run server: `uvicorn app.main:app --reload`

### Frontend Setup

1. Navigate to `bio_ai/`
2. Install dependencies: `flutter pub get`
3. Update `lib/core/config.dart` with backend URL if needed
4. Run app: `flutter run`

## Dependencies

### Backend

- `fastapi` - Web framework
- `requests` - HTTP client for FatSecret API
- `python-dotenv` - Environment variable loading
- `pillow` - Image processing
- `python-multipart` - File upload support

### Frontend

- `dio` - HTTP client
- `mobile_scanner` - Barcode scanning
- `camera` - Photo capture
- `flutter_riverpod` - State management

## Security Best Practices

✅ API keys stored in `.env` file
✅ `.env` added to `.gitignore`
✅ `.env.example` provided without secrets
✅ Backend acts as proxy (credentials never exposed to frontend)
✅ OAuth token caching to minimize auth requests

## Notes

- FatSecret API requires OAuth 2.0 client credentials flow
- Barcode format: UPC-A (12 digits) automatically converted to GTIN-13
- Image recognition supports JPEG/PNG, max 512x512 pixels
- Token cached with 60-second buffer before expiration
