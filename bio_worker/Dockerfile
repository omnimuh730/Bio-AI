FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app
ENV REDIS_URL="redis://redis:6379/0"
ENV MONGODB_URI="mongodb://mongo:27017"
CMD ["python", "-u", "app/main.py"]