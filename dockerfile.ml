# Dockerfile.ml (ML FastAPI)
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc && rm -rf /var/lib/apt/lists/*

# copy requirements and install
COPY ml/requirements.txt /app/ml/requirements.txt
RUN pip install --no-cache-dir -r /app/ml/requirements.txt

# copy ml code and saved_models
COPY ml/ /app/ml

ENV PYTHONUNBUFFERED=1
EXPOSE 5000

CMD ["uvicorn", "ml.backend:app", "--host", "0.0.0.0", "--port", "5000"]
