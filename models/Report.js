const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  warehouse_id: String,
  generated_by: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  generated_at: { type: Date, default: Date.now },
  report_type: String,
  report_link: String
});

module.exports = mongoose.model('Report', reportSchema);
