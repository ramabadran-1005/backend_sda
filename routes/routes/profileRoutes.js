const express = require('express');
const router = express.Router();
const UserProfile = require('../models/UserProfile');

// Create profile
router.post('/create', async (req, res) => {
  try {
    const profile = new UserProfile(req.body);
    await profile.save();
    res.status(201).json({ message: '✅ Profile created', profile });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
