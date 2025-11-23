// src/middleware/error.js
module.exports = (err, req, res, next) => {
  console.error('🔥 Error:', err.stack || err);
  const status = res.statusCode && res.statusCode !== 200 ? res.statusCode : 500;
  res.status(status).json({
    success: false,
    message: err.message || 'Server Error',
  });
};
