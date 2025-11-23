const mongoose = require('mongoose');

const deviceControlSchema = new mongoose.Schema({
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node' },
  timestamp: { type: Date, default: Date.now },
  action: String,
  status: String
});

module.exports = mongoose.model('DeviceControl', deviceControlSchema);
