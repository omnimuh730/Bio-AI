# Bio Mock Project Specifications

## Overview

The Bio Mock project serves as a streaming service for mock data, designed to operate in development and staging modes. It exposes streaming methods for live data, such as health data from HealthKit.

## Architecture

- **Frontend**: Built with React, the frontend will display streaming data in charts and numeric formats.
- **Backend**: A FastAPI application that streams data to the frontend.

## Frontend Configuration

- **Port**: The frontend will run on port 5193 to avoid conflicts.
- **Streaming Data**: The frontend will connect to the backend to receive live data updates.

## Backend Configuration

- **API Endpoint**: The backend will expose an endpoint at `/api/stream` to provide streaming data.

## Development Workflow

1. Start the backend service using Docker.
2. Start the frontend service using Yarn.
3. Access the frontend at `http://localhost:5193` to view live data streaming.

## Future Enhancements

- Implement authentication for secure data access.
- Add more data sources for diverse streaming options.
