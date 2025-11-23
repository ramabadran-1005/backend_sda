const mongoose = require('mongoose');
const fs = require('fs');
const csv = require('csv-parser');
const MasterData = require('./models/MasterDataModel');

// connect
mongoose.connect('mongodb://127.0.0.1:27017/nwarehouse')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error(err));

async function importCSV() {
  const results = [];

  fs.createReadStream('rc_ram.csv')
    .pipe(csv())
    .on('data', row => {
      // map CSV columns → value_1 … value_6
      results.push({
        warehouse_id: row.warehouse_id || 'W1',
        slot_id: row.slot_id || null,
        node_id: row.node_id || null,
        value_1: parseFloat(row.value_1 || row.temperature || 0),
        value_2: parseFloat(row.value_2 || row.humidity || 0),
        value_3: parseFloat(row.value_3 || row.vibration || 0),
        value_4: parseFloat(row.value_4 || 0),
        value_5: parseFloat(row.value_5 || 0),
        value_6: parseFloat(row.value_6 || 0),
      });
    })
    .on('end', async () => {
      try {
        await MasterData.insertMany(results);
        console.log(`✅ Inserted ${results.length} structured records.`);
        process.exit();
      } catch (err) {
        console.error('❌ Insert error:', err);
        process.exit(1);
      }
    });
}

importCSV();
