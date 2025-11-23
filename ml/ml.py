# ==========================
# ml_train.py — Simplified
# ==========================
import numpy as np
import pandas as pd
from pathlib import Path
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error
from sklearn.ensemble import ExtraTreesRegressor, IsolationForest
import joblib
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Conv1D, LSTM, Dropout, Dense
from tensorflow.keras.optimizers import Adam

# ---------------- Directories ----------------
models_dir = Path("saved_models")
models_dir.mkdir(exist_ok=True)

# ---------------- Load dataset ----------------
DF_PATH = "rc_ram.csv"  # adjust path if needed
df = pd.read_csv(DF_PATH, low_memory=False)

# Ensure NodeID numeric
df['NodeID'] = df['NodeID'].astype(str).str.extract(r'(\d+)')
df.dropna(subset=['NodeID'], inplace=True)
df['NodeID'] = df['NodeID'].astype(int)
df.fillna(method='ffill', inplace=True)
df.fillna(method='bfill', inplace=True)

# ---------------- Numeric columns ----------------
numeric_cols = [
    'Drift2620','Var2620','Flat2620',
    'Drift2600','Var2600','Flat2600',
    'Drift2602','Var2602','Flat2602',
    'Uptime_sec','Jitter_ms','RSSI_dBm','CPU_Temp_C','FreeHeap_bytes'
]
for c in numeric_cols:
    if c in df.columns:
        df[c] = pd.to_numeric(df[c], errors='coerce')
df.fillna(0, inplace=True)

# ---------------- Compute Risk_Score ----------------
existing_numeric = [c for c in numeric_cols if c in df.columns]
iso = IsolationForest(contamination=0.05, random_state=42)
df['Flag_IF'] = iso.fit_predict(df[existing_numeric])
df['Flag_IF'] = df['Flag_IF'].apply(lambda x: True if x == -1 else False)
df['Risk_Score'] = -iso.decision_function(df[existing_numeric])
df['Risk_Score'] = MinMaxScaler().fit_transform(df[['Risk_Score']])

# ---------------- Feature selection ----------------
SEQ_LEN = 50
exclude_cols = ['NodeID','Timestamp','Risk_Score','Flag_IF']
features = [c for c in df.columns if c not in exclude_cols]

# ---------------- Scale features ----------------
scaler = MinMaxScaler()
scaler.fit(df[features].values)
joblib.dump(scaler, models_dir / "global_scaler.joblib")

# ---------------- Sequence creation ----------------
def create_sequences(df, features, seq_len=SEQ_LEN, scaler=scaler):
    Xs, Ys = [], []
    for nid, g in df.groupby('NodeID'):
        arr = scaler.transform(g[features].values)
        target = g['Risk_Score'].values
        if len(arr) <= seq_len:
            continue
        for i in range(len(arr) - seq_len):
            Xs.append(arr[i:i+seq_len])
            Ys.append(target[i+seq_len])
    return np.array(Xs), np.array(Ys)

X, y = create_sequences(df, features, SEQ_LEN)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
INPUT_SHAPE = (SEQ_LEN, X.shape[2])

# ---------------- CNN-LSTM base model ----------------
def build_cnn_lstm(input_shape=INPUT_SHAPE):
    inp = Input(input_shape)
    x = Conv1D(64, 3, activation='relu', padding='same')(inp)
    x = LSTM(64)(x)
    x = Dropout(0.2)(x)
    x = Dense(64, activation='relu')(x)
    out = Dense(1)(x)
    m = Model(inp, out)
    m.compile(loss='mse', optimizer=Adam(5e-4), metrics=['mae'])
    return m

print("Training CNN-LSTM base model...")
base_model = build_cnn_lstm()
base_model.fit(X_train, y_train, epochs=5, batch_size=64, validation_split=0.15, verbose=1)
base_model.save(models_dir / "base_cnn_lstm.h5")
print("Base model saved: base_cnn_lstm.h5")

# ---------------- ExtraTrees meta regressor ----------------
print("Training ExtraTrees meta model...")
y_pred_base = base_model.predict(X_test).flatten()
meta_model = ExtraTreesRegressor(n_estimators=100, random_state=42)
meta_model.fit(y_pred_base.reshape(-1,1), y_test)
joblib.dump(meta_model, models_dir / "meta_extra_trees.joblib")
print("Meta model saved: meta_extra_trees.joblib")

# ---------------- Evaluation ----------------
y_meta_pred = meta_model.predict(y_pred_base.reshape(-1,1))
r2 = r2_score(y_test, y_meta_pred)
rmse = mean_squared_error(y_test, y_meta_pred, squared=False)
mae = mean_absolute_error(y_test, y_meta_pred)
print(f"Meta ExtraTrees → R2: {r2:.4f}, RMSE: {rmse:.4f}, MAE: {mae:.4f}")
