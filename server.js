

require("dotenv").config();
const express = require("express");
const helmet = require("helmet");
const compression = require("compression");
const cors = require("cors");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");
const bcrypt = require("bcrypt");


const admin = require("firebase-admin");

let serviceAccount;

// Render-safe: credentials come from ENV variable
if (process.env.FIREBASE_CREDENTIALS_JSON) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS_JSON);
  } catch (err) {
    console.error("❌ Failed to parse FIREBASE_CREDENTIALS_JSON:", err.message);
    process.exit(1);
  }
} else {
  console.error("❌ FIREBASE_CREDENTIALS_JSON is not set in Render");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(helmet());
app.use(compression());
app.use(cors({ origin: "*" }));
app.use(express.json({ limit: "10mb" }));
app.use(morgan("dev"));


app.use(
  "/api/",
  rateLimit({
    windowMs: 60 * 1000,
    max: 200,
  })
);


app.get("/healthz", (req, res) => {
  res.json({ status: "ok", uptime: process.uptime() });
});

// =========================
// API: MASTERDATA
// =========================
app.get("/api/masterdata", async (req, res) => {
  try {
    const snap = await db.collection("masterdatas").limit(1000).get();
    res.json(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// API: PREDICTIONS
// =========================
app.get("/api/predictions", async (req, res) => {
  try {
    const snap = await db.collection("predictions").get();
    res.json(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/predictions/latest", async (req, res) => {
  try {
    const snap = await db
      .collection("predictions")
      .orderBy("timestamp", "desc")
      .limit(100)
      .get();
    res.json(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// API: ALERTS
// =========================
app.get("/api/alerts", async (req, res) => {
  try {
    const snap = await db.collection("alerts").orderBy("timestamp", "desc").get();
    res.json(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/alerts", async (req, res) => {
  try {
    const alert = {
      nodeId: req.body.nodeId || "unknown",
      sensorType: req.body.sensorType || "unknown",
      message: req.body.message || "",
      timestamp: new Date().toISOString(),
    };
    const doc = await db.collection("alerts").add(alert);
    res.status(201).json({ id: doc.id, ...alert });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// AUTH: REGISTER & LOGIN
// =========================
app.post("/api/auth/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const exists = await db
      .collection("users")
      .where("email", "==", email)
      .get();

    if (!exists.empty) {
      return res.status(400).json({ error: "User exists" });
    }

    const hashed = await bcrypt.hash(password, 10);

    const doc = await db.collection("users").add({
      name,
      email,
      password: hashed,
      createdAt: new Date().toISOString(),
    });

    res.json({ message: "Registered", id: doc.id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const snap = await db
      .collection("users")
      .where("email", "==", email)
      .limit(1)
      .get();

    if (snap.empty) return res.status(404).json({ error: "User not found" });

    const user = snap.docs[0].data();
    const ok = await bcrypt.compare(password, user.password);

    if (!ok) return res.status(401).json({ error: "Wrong password" });

    res.json({ message: "Login ok", id: snap.docs[0].id, name: user.name });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});


app.listen(PORT, () => {
  console.log(`🔥 Server running on port ${PORT}`);
});
