from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Any, Dict
import os
import numpy as np
import joblib
import time
from datetime import datetime

app = FastAPI(title="NWarehouse ML (predict)", version="1.0")

# ----------------------------
# FIXED MODEL PATHS (WORKS ON RENDER)
# ----------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "saved_models")

BASE_MODEL_FILE = os.path.join(MODEL_PATH, "base_cnn_lstm.h5")
META_MODEL_FILE = os.path.join(MODEL_PATH, "meta_extra_trees.joblib")
SCALER_FILE = os.path.join(MODEL_PATH, "global_scaler.joblib")

base_model = None
meta_model = None
scaler = None
tensorflow_available = False

# ----------------------------
# OPTIONAL TENSORFLOW
# ----------------------------
try:
    import tensorflow as tf
    tensorflow_available = True
except Exception:
    tensorflow_available = False

# ----------------------------
# LOAD BASE MODEL
# ----------------------------
if tensorflow_available and os.path.exists(BASE_MODEL_FILE):
    try:
        base_model = tf.keras.models.load_model(BASE_MODEL_FILE)
        print("Loaded base model:", BASE_MODEL_FILE)
    except Exception as e:
        print("Failed to load base model:", e)
        base_model = None
else:
    print("Base model file not found or TF not available:", BASE_MODEL_FILE)

# ----------------------------
# LOAD META MODEL
# ----------------------------
if os.path.exists(META_MODEL_FILE):
    try:
        meta_model = joblib.load(META_MODEL_FILE)
        print("Loaded meta model:", META_MODEL_FILE)
    except Exception as e:
        print("Failed to load meta model:", e)
else:
    print("Meta model file not found:", META_MODEL_FILE)

# ----------------------------
# LOAD SCALER
# ----------------------------
if os.path.exists(SCALER_FILE):
    try:
        scaler = joblib.load(SCALER_FILE)
        print("Loaded scaler:", SCALER_FILE)
    except Exception as e:
        print("Failed to load scaler:", e)
else:
    print("Scaler file not found:", SCALER_FILE)


# ----------------------------
# REQUEST PAYLOAD
# ----------------------------
class PredictPayload(BaseModel):
    sequence: List[List[float]]
    nodeId: Optional[Any] = None


# ----------------------------
# NORMALIZE SCORE
# ----------------------------
def normalize_score(raw: float) -> float:
    try:
        r = float(raw)
    except:
        return 0.0

    if 0 <= r <= 1:
        return r * 100
    return min(max(r, 0), 100)


# ----------------------------
# CLASSIFICATION
# ----------------------------
def classify(score: float) -> Dict[str, str]:
    if score <= 50:
        binary = "Healthy"
    else:
        binary = "Faulty"

    if score <= 20:
        ternary = "Good"
    elif score <= 50:
        ternary = "Warning"
    else:
        ternary = "Critical"

    if score <= 10:
        return dict(binary=binary, ternary=ternary, four_class="Normal", health_state="Healthy", ops_mode="Normal Operation")
    if score <= 40:
        return dict(binary=binary, ternary=ternary, four_class="Alert", health_state="Degraded", ops_mode="Monitor")
    if score <= 75:
        return dict(binary=binary, ternary=ternary, four_class="Failure Likely", health_state="Unstable", ops_mode="Prepare Maintenance")
    
    return dict(binary=binary, ternary=ternary, four_class="Failure Imminent", health_state="Failed", ops_mode="Shutdown / Replace Node")


# ----------------------------
# HEURISTIC FALLBACK
# ----------------------------
def heuristic_score(sequence: List[List[float]]) -> float:
    arr = np.array(sequence, float)
    if arr.size == 0:
        return 0.0

    # If scaler available
    if scaler is not None:
        try:
            scaled = scaler.transform([arr.mean(axis=0)])[0]
            return float(np.mean(scaled) * 100)
        except:
            pass

    # If 3 sensors
    if arr.shape[-1] == 3:
        w = np.array([0.4, 0.3, 0.3])
        x = arr[-1]
        denom = np.max(x) if np.max(x) != 0 else 1
        return float(np.dot(w, x / denom) * 100)

    avg = float(np.mean(arr))
    return min(100, avg)


# ----------------------------
# PREDICT ROUTE
# ----------------------------
@app.post("/predict")
async def predict(payload: PredictPayload):
    seq_arr = np.array(payload.sequence, float)
    model_used = "heuristic"
    score = 0.0

    # base + scaler
    if base_model is not None and scaler is not None:
        try:
            flat = seq_arr.reshape(-1, seq_arr.shape[-1])
            scaled = scaler.transform(flat)
            x = scaled.reshape((1, scaled.shape[0], scaled.shape[1]))
            bp = float(np.mean(base_model.predict(x, verbose=0)))
            model_used = "base"

            if meta_model:
                mp = meta_model.predict([[bp]])[0]
                score = normalize_score(mp)
                model_used = "meta"
            else:
                score = normalize_score(bp)

        except:
            score = heuristic_score(payload.sequence)

    # meta only
    elif meta_model is not None:
        try:
            guess = heuristic_score(payload.sequence) / 100
            mp = meta_model.predict([[guess]])[0]
            score = normalize_score(mp)
            model_used = "meta"
        except:
            score = heuristic_score(payload.sequence)

    else:
        score = heuristic_score(payload.sequence)

    out = classify(score)
    return {
        "nodeId": payload.nodeId,
        "riskScore": round(score, 3),
        **out,
        "model_used": model_used,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }


@app.get("/")
def hello():
    return {
        "ok": True,
        "models": {
            "base": bool(base_model),
            "meta": bool(meta_model),
            "scaler": bool(scaler),
        }
    }
