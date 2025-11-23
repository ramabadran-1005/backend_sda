const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  name: { type: String, required: true },
  warehouse_id: { type: String, required: true, unique: true }, // user-defined
  staff_id: { type: String },
  aadhar_last4: { type: String, required: true }, // new addition
  mobile_no: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  address: { type: String },
  is_verified: { type: Boolean, default: false },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('UserProfile', userProfileSchema);
