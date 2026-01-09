from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Any, Dict
import os
import numpy as np
import joblib
import time
from datetime import datetime

app = FastAPI(title="NWarehouse ML (predict)", version="1.0")

MODEL_PATH = os.environ.get("MODEL_PATH", "/app/saved_models")

BASE_MODEL_FILE = os.path.join(MODEL_PATH, "base_cnn_lstm.h5")
META_MODEL_FILE = os.path.join(MODEL_PATH, "meta_extra_trees.joblib")
SCALER_FILE = os.path.join(MODEL_PATH, "global_scaler.joblib")

base_model = None
meta_model = None
scaler = None

tensorflow_available = False
try:
    import tensorflow as tf
    tensorflow_available = True
except:
    tensorflow_available = False

if tensorflow_available and os.path.exists(BASE_MODEL_FILE):
    try:
        base_model = tf.keras.models.load_model(BASE_MODEL_FILE)
    except:
        base_model = None

if os.path.exists(META_MODEL_FILE):
    try:
        meta_model = joblib.load(META_MODEL_FILE)
    except:
        meta_model = None

if os.path.exists(SCALER_FILE):
    try:
        scaler = joblib.load(SCALER_FILE)
    except:
        scaler = None


class PredictPayload(BaseModel):
    sequence: List[List[float]]
    nodeId: Optional[Any] = None


def normalize_score(raw: float) -> float:
    try:
        r = float(raw)
    except:
        return 0.0

    if 0.0 <= r <= 1.0:
        return r * 100

    if r < 0:
        return 0
    if r > 100:
        return 100
    return r


def classify(score: float) -> Dict[str, str]:
    binary = "Healthy" if score <= 50 else "Faulty"

    if score <= 20:
        ternary = "Good"
    elif score <= 50:
        ternary = "Warning"
    else:
        ternary = "Critical"

    if score <= 10:
        four_class = "Normal"
        health_state = "Healthy"
        ops_mode = "Normal Operation"
    elif score <= 40:
        four_class = "Alert"
        health_state = "Degraded"
        ops_mode = "Monitor"
    elif score <= 75:
        four_class = "Failure Likely"
        health_state = "Unstable"
        ops_mode = "Prepare Maintenance"
    else:
        four_class = "Failure Imminent"
        health_state = "Failed"
        ops_mode = "Shutdown / Replace Node"

    return {
        "binary": binary,
        "ternary": ternary,
        "four_class": four_class,
        "health_state": health_state,
        "ops_mode": ops_mode,
    }


@app.post("/predict")
async def predict(payload: PredictPayload):
    seq = payload.sequence
    if not seq:
        raise HTTPException(status_code=400, detail="Sequence missing")

    seq_arr = np.array(seq, dtype=float)

    if base_model is None and meta_model is None and scaler is None:
        score = float(np.mean(seq_arr))
        return {"riskScore": score, "model_used": "fallback"}

    try:
        latest = seq_arr[-1]
        denom = np.max(latest) if np.max(latest) > 0 else 1
        raw = float(np.mean(latest / denom))
        score = normalize_score(raw * 100)
    except:
        score = 0

    cls = classify(score)

    return {
        "nodeId": payload.nodeId,
        "riskScore": round(score, 4),
        **cls,
        "model_used": "fallback",
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }


@app.get("/")
def check():
    return {
        "ok": True,
        "models": {
            "base": bool(base_model),
            "meta": bool(meta_model),
            "scaler": bool(scaler)
        }
    }
