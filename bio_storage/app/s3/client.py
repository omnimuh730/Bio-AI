import boto3
from botocore.exceptions import ClientError
from app.core.config import settings
import logging

log = logging.getLogger(__name__)

class S3Client:
    def __init__(self):
        kwargs = {}
        if settings.s3_endpoint_url:
            kwargs["endpoint_url"] = settings.s3_endpoint_url
        if settings.s3_access_key and settings.s3_secret_key:
            kwargs["aws_access_key_id"] = settings.s3_access_key
            kwargs["aws_secret_access_key"] = settings.s3_secret_key
        self.client = boto3.client("s3", region_name=settings.s3_region, **kwargs)
        self.hot_bucket = settings.s3_bucket_hot
        self.archive_bucket = settings.s3_bucket_archive

    def ensure_buckets(self):
        for bucket in (self.hot_bucket, self.archive_bucket):
            try:
                self.client.head_bucket(Bucket=bucket)
            except ClientError:
                try:
                    self.client.create_bucket(Bucket=bucket)
                    log.info("Created bucket %s", bucket)
                except Exception as exc:
                    log.warning("Could not create bucket %s: %s", bucket, exc)

    def upload_fileobj(self, fileobj, key, content_type: str | None = None):
        extra = {}
        if content_type:
            extra["ContentType"] = content_type
        self.client.put_object(Bucket=self.hot_bucket, Key=key, Body=fileobj.read(), **extra)

    def copy_to_archive(self, key):
        copy_source = {"Bucket": self.hot_bucket, "Key": key}
        self.client.copy_object(CopySource=copy_source, Bucket=self.archive_bucket, Key=key)

    def delete_object(self, bucket, key):
        self.client.delete_object(Bucket=bucket, Key=key)

    def object_exists(self, bucket, key) -> bool:
        try:
            self.client.head_object(Bucket=bucket, Key=key)
            return True
        except ClientError:
            return False

s3_client = S3Client()