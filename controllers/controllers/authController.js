const jwt = require('jsonwebtoken');
const User = require('../models/User');
const send = require('../src/utils/sendResponse');
const wrap = require('../src/utils/catchAsync');
const { JWT_SECRET } = require('../src/config/env');

exports.register = wrap(async (req, res) => {
  const { username, password, role } = req.body;
  if (!username || !password || !role) return send(res, { status:400, success:false, message:'All fields are required' });
  if (await User.findOne({ username })) return send(res, { status:400, success:false, message:'User already exists' });
  await new User({ username, password, role }).save(); // hashed by model hook
  return send(res, { message:'User registered successfully' });
});

exports.login = wrap(async (req, res) => {
  const { username, password } = req.body;
  const user = await User.findOne({ username });
  if (!user || !(await user.comparePassword(password)))
    return send(res, { status:400, success:false, message:'Invalid credentials' });

  const token = jwt.sign({ userId:user._id, role:user.role }, JWT_SECRET, { expiresIn:'1d' });
  return send(res, { message:'Login successful', data:{ token, user:{ id:user._id, username:user.username, role:user.role } } });
});
