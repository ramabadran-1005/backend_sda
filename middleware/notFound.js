// src/middleware/notFound.js
module.exports = (req, res, next) => {
    res.status(404);
    res.json({
      success: false,
      message: `Not Found - ${req.originalUrl}`,
    });
  };
  