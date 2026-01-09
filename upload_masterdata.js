/**
 * Upload Master Data CSV to Firestore
 */

require("dotenv").config();
const admin = require("firebase-admin");
const fs = require("fs");
const csv = require("csv-parser");

let serviceAccount;

// ----------------------
// LOCAL USE (serviceAccountKey.json file)
// ----------------------
if (fs.existsSync("./serviceAccountKey.json")) {
  console.log("🔑 Using local serviceAccountKey.json");
  serviceAccount = require("./serviceAccountKey.json");
}

// ----------------------
// RENDER USE (env variable)
// ----------------------
else if (process.env.FIREBASE_CREDENTIALS_JSON) {
  console.log("🔐 Using FIREBASE_CREDENTIALS_JSON from Render");
  serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS_JSON);
}

// ----------------------
else {
  console.error("❌ No Firebase credentials available!");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ----------------------
// CSV FILE
// ----------------------
const CSV_FILE = "rc_ram.csv";

if (!fs.existsSync(CSV_FILE)) {
  console.error("❌ CSV file not found:", CSV_FILE);
  process.exit(1);
}

// ----------------------
// UPLOAD
// ----------------------
async function uploadCSV() {
  console.log("📥 Reading CSV:", CSV_FILE);

  let rows = [];

  fs.createReadStream(CSV_FILE)
    .pipe(csv())
    .on("data", (row) => rows.push(row))
    .on("end", async () => {
      console.log(`📦 Loaded ${rows.length} rows`);

      for (let i = 0; i < rows.length; i++) {
        await db.collection("masterdatas").add({
          ...rows[i],
          uploadedAt: new Date().toISOString(),
        });

        console.log(`✔ Uploaded ${i + 1}/${rows.length}`);
      }

      console.log("🎉 Upload complete");
      process.exit(0);
    });
}

uploadCSV();
