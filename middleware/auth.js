const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config/env');

module.exports = (required = true) => (req, res, next) => {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.split(' ')[1] : null;
  if (!token) return required ? res.status(401).json({ success:false, message:'Missing token' }) : next();
  try { req.user = jwt.verify(token, JWT_SECRET); next(); }
  catch { return res.status(401).json({ success:false, message:'Invalid token' }); }
};
