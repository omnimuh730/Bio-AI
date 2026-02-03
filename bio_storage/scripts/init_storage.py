from app.s3.client import s3_client

if __name__ == "__main__":
    s3_client.ensure_buckets()
    print("Buckets ensured")
