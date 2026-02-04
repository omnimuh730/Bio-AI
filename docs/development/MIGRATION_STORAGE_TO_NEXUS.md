# Bio Storage to Bio Nexus Migration Guide

**Date:** February 4, 2026  
**Status:** ✅ Complete

## Summary

`bio_storage` has been successfully merged into `bio_nexus` to simplify the microservices architecture and reduce operational overhead. Both services used MongoDB, making consolidation straightforward.

## What Changed

### Service Architecture

- **Before:** Two separate services (bio_nexus + bio_storage)
- **After:** Single unified service (bio_nexus with storage capabilities)

### API Endpoints

All storage endpoints have been moved under the `/api/v1/storage/` prefix:

| Old Endpoint (bio_storage)           | New Endpoint (bio_nexus)                               |
| ------------------------------------ | ------------------------------------------------------ |
| POST /api/v1/files                   | POST /api/v1/storage/files                             |
| GET /api/v1/files/{file_id}          | GET /api/v1/storage/files/{file_id}                    |
| POST /api/v1/files/{file_id}/archive | POST /api/v1/storage/files/{file_id}/archive           |
| N/A                                  | POST /api/v1/storage/sign-upload (new)                 |
| N/A                                  | GET /api/v1/storage/files/{file_id}/download-url (new) |

### Configuration Changes

**New environment variables added to bio_nexus:**

```bash
# S3 Storage Configuration
S3_ENDPOINT_URL=http://minio:9000
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
BUCKET_HOT=bio-storage-hot
BUCKET_ARCHIVE=bio-storage-archive
ARCHIVE_THRESHOLD_DAYS=30
```

### Database Collections

The `files` collection from `bio_storage_db` should be migrated to `bio_nexus_db`:

```javascript
// MongoDB migration
db.getSiblingDB("bio_storage_db")
	.files.find()
	.forEach(function (doc) {
		db.getSiblingDB("bio_nexus_db").files.insert(doc);
	});
```

### Code Structure Changes

**New files in bio_nexus:**

```
bio_nexus/app/
├── s3/
│   ├── client.py              # S3 client with presigned URL support
│   └── __init__.py
├── services/
│   └── storage.py             # File upload/archive logic
└── api/v1/endpoints/
    └── storage.py             # Storage API endpoints
```

## Migration Steps for Clients

### 1. Update API URLs

Change all references from `http://bio-storage:8000/api/v1/files` to `http://bio-nexus:8000/api/v1/storage/files`

### 2. Update Environment Configuration

- Remove bio_storage deployment/pod
- Add S3 configuration to bio_nexus environment variables
- Update DNS/service discovery entries

### 3. Update Dependencies

No changes to requirements for existing bio_nexus clients. New boto3 dependency added for S3 operations.

### 4. Use New Presigned URL Flow (Recommended)

Instead of uploading files through the API, use the new presigned URL flow:

```python
# Step 1: Request upload credentials
response = requests.post(
    "http://bio-nexus:8000/api/v1/storage/sign-upload",
    json={
        "filename": "food_image.jpg",
        "content_type": "image/jpeg",
        "use_case": "vision_scan"
    }
)
upload_url = response.json()["upload_url"]
file_id = response.json()["file_id"]

# Step 2: Upload directly to S3 (bypasses the API)
requests.put(upload_url, data=file_content, headers={"Content-Type": "image/jpeg"})

# Step 3: Use file_id in subsequent API calls
```

## Benefits

1. **Reduced Operational Complexity:** One less service to deploy, monitor, and maintain
2. **Shared Database Connection:** Better connection pool utilization
3. **Simplified Development:** Single codebase for data + storage operations
4. **Lower Costs:** One MongoDB cluster, one deployment, fewer resources
5. **Better Integration:** File metadata naturally lives alongside vision results and food logs

## Rollback Plan

If issues arise, the old bio_storage service code is preserved in git history (commit before Feb 4, 2026). Rollback requires:

1. Restore bio_storage directory from git
2. Deploy bio_storage service
3. Update client URLs back to bio_storage endpoints

## Testing Checklist

- [x] S3 bucket initialization on startup
- [x] Presigned upload URL generation
- [x] Presigned download URL generation
- [x] File metadata storage in MongoDB
- [x] File archival (hot → cold bucket)
- [x] Direct file upload (legacy endpoint)
- [x] API endpoint routing
- [x] Environment variable configuration
- [x] Documentation updates

## Support

For issues or questions, contact the platform team or check the updated [bionexus_specs.md](./bionexus_specs.md) documentation.
