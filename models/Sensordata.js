// models/gasSensorData.js
const mongoose = require('mongoose');

const sensorDataSchema = new mongoose.Schema({
  nodeId: { type: String, required: true },
  warehouseId: { type: String },
  slotId: { type: String },
  TGS2620: { type: Number, required: true },
  TGS2602: { type: Number, required: true },
  TGS2600: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('SensorData', sensorDataSchema);
