const mongoose = require('mongoose');

const preDeploymentSchema = new mongoose.Schema({
  warehouse_id: { type: String, required: true, unique: true },
  warehouse_name: { type: String },
  total_slots: { type: Number },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('PreDeployment', preDeploymentSchema);
