const mongoose = require('mongoose');
const MasterData = require('./models/MasterDataModel');

mongoose.connect('mongodb://127.0.0.1:27017/nwarehouse')
  .then(async () => {
    const count = await MasterData.countDocuments();
    console.log(`✅ Total records in DB: ${count}`);
    const one = await MasterData.findOne();
    console.log('🧩 Sample record:', one);
    process.exit();
  })
  .catch(err => console.error('❌ DB error:', err));

