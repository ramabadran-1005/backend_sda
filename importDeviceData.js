const mongoose = require('mongoose');
const fs = require('fs');
const csv = require('csv-parser');
const MasterData = require('./models/MasterDataModel'); // adjust if path differs

// ✅ Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/nwarehouse', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connected to MongoDB'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// ✅ Load CSV data
async function importCSV() {
  const results = [];

  fs.createReadStream('rc_ram.csv') // <-- your uploaded file name
    .pipe(csv())
    .on('data', (row) => {
      // Customize mapping based on CSV headers
      results.push({
        device_id: row.device_id || `dev-${Math.floor(Math.random() * 1000)}`,
        temperature: parseFloat(row.temperature || 0),
        humidity: parseFloat(row.humidity || 0),
        vibration: parseFloat(row.vibration || 0),
        status: row.status || "normal",
        timestamp: new Date(),
      });
    })
    .on('end', async () => {
      try {
        await MasterData.insertMany(results);
        console.log(`✅ Inserted ${results.length} records successfully.`);
        process.exit();
      } catch (err) {
        console.error('❌ Error inserting data:', err);
        process.exit(1);
      }
    })
}

importCSV();
