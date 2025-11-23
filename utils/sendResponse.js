module.exports = (res, { status=200, success=true, message='OK', data=null }) =>
  res.status(status).json({ success, message, data });
