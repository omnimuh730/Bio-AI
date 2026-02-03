# Bio Mock - Streaming Mock Data Service

Bio Mock is a mock data streaming service designed for development and staging environments. It simulates real-time health data streaming (like HealthKit data) that can be consumed by the bio_ai Flutter mobile app and the streaming-frontend web dashboard.

## Overview

This project provides:

- **Streaming Backend**: A FastAPI service that streams mock health data via Server-Sent Events (SSE)
- **Streaming Frontend**: A React dashboard to visualize real-time streaming data in charts and numeric displays
- **In-Memory Storage**: Temporarily stores the last 10,000 data points for quick access

## Architecture

```
bio_mock/
├── backend/                    # FastAPI streaming backend
│   ├── app.py                 # Main application with /api/stream endpoint
│   ├── requirements.txt        # Python dependencies
│   └── Dockerfile             # Docker configuration
├── streaming-frontend/         # React web dashboard
│   ├── src/
│   │   ├── App.jsx            # Main app component
│   │   ├── components/
│   │   │   └── Chart.jsx      # Streaming data visualization
│   │   └── main.jsx
│   ├── package.json
│   ├── vite.config.js         # Vite config (port 5193)
│   └── Dockerfile
└── docker-compose.yml         # Multi-service orchestration
```

## Getting Started

### Prerequisites

- Node.js 16+ (for frontend)
- Python 3.8+ (for backend)
- Docker & Docker Compose (optional)

### Installation

#### Option 1: Using Docker Compose

```bash
cd bio_mock
docker-compose up
```

#### Option 2: Manual Setup

**Backend:**

```bash
cd bio_mock/backend
pip install -r requirements.txt
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

**Frontend:**

```bash
cd bio_mock/streaming-frontend
npm install
npm run dev
```

## Usage

Once running, access the services at:

- **Frontend Dashboard**: `http://localhost:5193`
- **Backend API**: `http://localhost:8000/api/stream`

### Streaming Endpoint

The backend exposes a single streaming endpoint:

```
GET /api/stream
```

Returns Server-Sent Events (SSE) with mock health data every second.

**Example data format:**

```json
{
	"value": 42,
	"timestamp": "2026-02-03T10:30:00Z",
	"type": "heart_rate"
}
```

## Environment Modes

- **Development**: Run locally with hot reload enabled
- **Staging**: Production-like environment with Docker containers

## Data Storage

- **In-Memory Buffer**: Stores the last 10,000 data points
- **No Database**: Data is temporary and not persisted
- **Auto-Cleanup**: Oldest data is automatically removed when buffer reaches 10,000 points

## Integration with bio_ai

The Flutter app can consume this streaming data in dev mode by configuring the HTTP client to connect to:

```
http://localhost:8000/api/stream
```

## API Documentation

### Stream Endpoint

- **Method**: GET
- **Path**: `/api/stream`
- **Response Type**: Server-Sent Events (text/event-stream)
- **Content**: Continuous stream of JSON data objects
- **Update Frequency**: Every 1 second

## Development

### Adding New Data Sources

Edit `backend/app.py` to modify the mock data generation:

```python
# Replace mock data generation logic
data = {
    'value': 42,  # Your actual data here
    'timestamp': datetime.now().isoformat(),
    'type': 'sensor_type'
}
```

### Customizing Frontend Display

Edit `streaming-frontend/src/components/Chart.jsx` to add:

- Chart visualizations
- Numeric displays
- Data filtering
- Real-time metrics

## Troubleshooting

**Port Already in Use**:

- Frontend uses port 5193 (change in `vite.config.js`)
- Backend uses port 8000 (change in Docker Compose or uvicorn command)

**CORS Issues**:

- Backend has CORS middleware enabled for all origins
- Safe for development; restrict in production

**No Data Appearing**:

- Ensure backend is running on `http://localhost:8000`
- Check browser console for WebSocket/SSE errors
- Verify frontend is configured to connect to correct backend URL

## Future Enhancements

- [ ] Real HealthKit data integration
- [ ] Multiple data source simulation (heart rate, steps, sleep, etc.)
- [ ] Data replay functionality
- [ ] Historical data queries
- [ ] WebSocket support as alternative to SSE
- [ ] Advanced charting with real-time metrics
- [ ] Authentication & authorization

## License

Part of the Bio AI project.
