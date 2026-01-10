// app.cjs — Render + MongoDB Atlas (STABLE)

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const axios = require('axios');

const app = express();

/* -------------------- MIDDLEWARE -------------------- */
app.use(express.json({ limit: '30mb' }));
app.use(cors({ origin: '*' }));
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));

/* -------------------- CONFIG -------------------- */
const PORT = process.env.PORT || 10000;
const MONGO_URI = process.env.MONGO_URI;
const DB_NAME = 'nwarehouse';
const ML_BASE = process.env.ML_BASE || 'https://fastapi-2-bj9b.onrender.com';

if (!MONGO_URI) {
  console.error('❌ MONGO_URI missing');
  process.exit(1);
}

/* -------------------- DB STATE -------------------- */
let mongoConnected = false;
let database = null;

/* -------------------- UTILS -------------------- */
function cleanNodeId(raw) {
  if (raw === undefined || raw === null) return null;
  const m = String(raw).match(/\d+/g);
  return m ? Number(m.join('')) : null;
}

/* -------------------- CONNECT MONGO -------------------- */
async function connectMongo() {
  try {
    await mongoose.connect(MONGO_URI, {
      dbName: DB_NAME,
      serverSelectionTimeoutMS: 10000,
    });

    database = mongoose.connection.db;
    mongoConnected = true;
    console.log('✅ MongoDB Atlas connected');
  } catch (err) {
    mongoConnected = false;
    console.error('❌ MongoDB connection failed:', err.message);
  }
}

connectMongo();

/* Auto reconnect (Render safe) */
setInterval(() => {
  if (!mongoConnected) {
    console.log('🔁 Reconnecting MongoDB...');
    connectMongo();
  }
}, 15000);

/* -------------------- DB HELPER -------------------- */
function getDb(res) {
  if (!mongoConnected || !database) {
    res.status(503).json({ error: 'DB not available' });
    return null;
  }
  return database;
}

/* -------------------- HEALTH -------------------- */
app.get('/healthz', (req, res) => {
  res.json({
    ok: true,
    mongoConnected,
    dbName: DB_NAME,
    mlBase: ML_BASE,
  });
});

/* -------------------- MASTERDATA -------------------- */
app.get('/api/masterdata', async (req, res) => {
  const db = getDb(res);
  if (!db) return;

  const limit = Math.min(2000, Number(req.query.limit || 200));
  const query = {};

  if (req.query.nodeId) {
    const nid = cleanNodeId(req.query.nodeId);
    if (nid !== null) query.NodeID = nid;
  }

  // ⚠️ NO SORT — prevents empty result bug
  const rows = await db
    .collection('masterdatas')
    .find(query)
    .limit(limit)
    .toArray();

  res.json(rows);
});

app.post('/api/masterdata', async (req, res) => {
  const db = getDb(res);
  if (!db) return;

  const payload = Array.isArray(req.body)
    ? req.body.map(d => ({
        ...d,
        NodeID: cleanNodeId(d.NodeID ?? d.nodeId),
        receivedAt: new Date(),
      }))
    : {
        ...req.body,
        NodeID: cleanNodeId(req.body.NodeID ?? req.body.nodeId),
        receivedAt: new Date(),
      };

  const result = Array.isArray(payload)
    ? await db.collection('masterdatas').insertMany(payload)
    : await db.collection('masterdatas').insertOne(payload);

  res.status(201).json(result);
});

/* -------------------- ALERTS -------------------- */
app.get('/api/alerts', async (req, res) => {
  const db = getDb(res);
  if (!db) return;

  const limit = Number(req.query.limit || 100);

  const rows = await db
    .collection('alerts')
    .find()
    .limit(limit)
    .toArray();

  res.json(rows);
});

/* -------------------- LIVE NODES -------------------- */
app.get('/api/live-nodes', async (req, res) => {
  const db = getDb(res);
  if (!db) return;

  const windowMs = Number(req.query.window || 15) * 1000;
  const now = Date.now();

  // ⚠️ NO SORT
  const rows = await db
    .collection('masterdatas')
    .find()
    .limit(5000)
    .toArray();

  const lastSeen = {};

  for (const r of rows) {
    const id = cleanNodeId(r.NodeID ?? r.nodeId);
    if (id === null) continue;

    const ts =
      r.receivedAt ? new Date(r.receivedAt).getTime()
      : r.Timestamp ? new Date(r.Timestamp).getTime()
      : null;

    if (!ts || isNaN(ts)) continue;

    if (!lastSeen[id] || ts > lastSeen[id]) {
      lastSeen[id] = ts;
    }
  }

  const nodes = Object.entries(lastSeen)
    .filter(([_, ts]) => now - ts < windowMs)
    .map(([id, ts]) => ({
      nodeId: Number(id),
      lastSeen: new Date(ts).toISOString(),
    }));

  res.json({ nodes, count: nodes.length });
});

/* -------------------- PREDICTIONS -------------------- */
app.post('/api/predictions/predict', async (req, res) => {
  try {
    const mlResp = await axios.post(`${ML_BASE}/predict`, req.body, {
      timeout: 20000,
    });

    if (mongoConnected && database) {
      await database.collection('predictions').insertOne({
        ...mlResp.data,
        nodeId: cleanNodeId(req.body.nodeId ?? req.body.NodeID),
        createdAt: new Date(),
      });
    }

    res.json(mlResp.data);
  } catch (e) {
    console.error('ML error:', e.message);
    res.status(500).json({ error: 'ML service failed' });
  }
});

/* -------------------- FALLBACK -------------------- */
app.use((req, res) => res.status(404).json({ error: 'Not Found' }));

/* -------------------- START -------------------- */
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
