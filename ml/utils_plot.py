# ml/utils_plot.py
import matplotlib.pyplot as plt
import pandas as pd

history = pd.read_csv("ml/saved_models/training_history.csv")

plt.figure()
plt.plot(history['epoch'], history['loss'], label='Loss')
plt.plot(history['epoch'], history['mae'], label='MAE')
plt.legend()
plt.title("Training Loss/MAE vs Epochs")
plt.show()
