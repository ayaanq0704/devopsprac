# version: '3.8'

# services:
#   web:
#     build: .
#     container_name: url-shortener
#     ports:
#       - "5000:5000"
#     volumes:
#       # Persist database outside container so data survives restarts
#       - ./data:/app/instance
#     environment:
#       - FLASK_ENV=production
#     restart: unless-stopped
#     healthcheck:
#       test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
#       interval: 30s
#       timeout: 10s
#       retries: 3


FROM python:3.10-slim

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]