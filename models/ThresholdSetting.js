const mongoose = require('mongoose');

const thresholdSettingSchema = new mongoose.Schema({
  warehouse_id: { type: String, ref: 'UserProfile', required: true },
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node', required: true },
  sensor_name: String, // 'CO2', 'Gas', etc.
  min_value: Number,
  max_value: Number,
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ThresholdSetting', thresholdSettingSchema);
