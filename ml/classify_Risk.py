# ml/classify_risks.py
import numpy as np
import pandas as pd
import tensorflow as tf
import joblib

MODEL_PATH = "ml/saved_models/base_cnn_lstm.h5"
SCALER_PATH = "ml/saved_models/global_scaler.joblib"
SEQ_LEN = 50

FEATURES = [
    'TGS2620','TGS2602','TGS2600',
    'Drift2620','Var2620','Flat2620',
    'Drift2600','Var2600','Flat2600',
    'Drift2602','Var2602','Flat2602',
    'Uptime_sec','Jitter_ms','RSSI_dBm','CPU_Temp_C','FreeHeap_bytes'
]

model = tf.keras.models.load_model(MODEL_PATH, compile=False)
scaler = joblib.load(SCALER_PATH)

def classify_labels(r):
    r = float(r)
    return {
        "Binary": "Healthy" if r <= 0.5 else "Faulty",
        "Ternary": "Stable" if r <= 0.4 else "Under Observation" if r <= 0.7 else "Critical",
        "Four-Class": "Safe" if r <= 0.25 else "Warning" if r <= 0.5 else "Danger" if r <= 0.75 else "Failure Imminent",
        "State": "Fresh" if r <= 0.2 else "Degrading" if r <= 0.5 else "Fault Likely" if r <= 0.8 else "Failed",
        "OpsMode": "Normal" if r <= 0.3 else "Monitor" if r <= 0.6 else "Maintenance" if r <= 0.85 else "Shutdown"
    }

# load data
df = pd.read_csv("data/test_dataset.csv")[FEATURES].fillna(0)

seq = df.to_numpy(np.float32)
if len(seq) < SEQ_LEN:
    pad = np.zeros((SEQ_LEN - len(seq), seq.shape[1]), np.float32)
    seq = np.vstack([pad, seq])
else:
    seq = seq[-SEQ_LEN:]

seq_scaled = scaler.transform(seq)
seq_scaled = np.expand_dims(seq_scaled, axis=0)

pred = float(model.predict(seq_scaled)[0][0])
pred = np.clip(pred, 0, 1)

labels = classify_labels(pred)
result = pd.DataFrame([{**labels, "Risk Score": round(pred,4)}])
result.to_csv("ml/saved_models/risk_output.csv", index=False)
print(result)
