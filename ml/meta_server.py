from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)
meta_model = joblib.load("ml/meta_extra_trees.joblib")  # make sure path matches

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    if not isinstance(data, list):
        return jsonify({"error": "Input must be a list"}), 400
    prediction = meta_model.predict([data])
    return jsonify(prediction.tolist())

if __name__ == "__main__":
    app.run(port=5001)
