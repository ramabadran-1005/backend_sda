# ml/convert_tflite.py
import tensorflow as tf

MODEL_PATH = "ml/saved_models/base_cnn_lstm.h5"
TFLITE_PATH = "ml/saved_models/base_cnn_lstm.tflite"

model = tf.keras.models.load_model(MODEL_PATH, compile=False)
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open(TFLITE_PATH, "wb") as f:
    f.write(tflite_model)

print(f"✅ Model converted and saved at {TFLITE_PATH}")
