// app.cjs — FINAL STABLE (Render + MongoDB Atlas)

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');

const app = express();

/* -------------------- MIDDLEWARE -------------------- */
app.use(express.json({ limit: '20mb' }));
app.use(cors({ origin: '*' }));
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));

/* -------------------- CONFIG -------------------- */
const PORT = process.env.PORT || 10000;
const MONGO_URI = process.env.MONGO_URI;
const DB_NAME = 'NWARE';

if (!MONGO_URI) {
  console.error('❌ MONGO_URI missing');
  process.exit(1);
}

/* -------------------- CONNECT MONGO -------------------- */
mongoose
  .connect(MONGO_URI, {
    dbName: DB_NAME,
    serverSelectionTimeoutMS: 10000,
  })
  .then(() => console.log('✅ MongoDB Atlas connected'))
  .catch(err => {
    console.error('❌ MongoDB connection failed:', err.message);
    process.exit(1);
  });

const db = () => mongoose.connection.db;

/* -------------------- HEALTH -------------------- */
app.get('/healthz', (req, res) => {
  res.json({
    ok: true,
    mongoConnected: mongoose.connection.readyState === 1,
    dbName: DB_NAME,
  });
});

/* -------------------- MASTERDATA -------------------- */
app.get('/api/masterdata', async (req, res) => {
  const rows = await db()
    .collection('masterdatas')
    .find({})
    .limit(200)
    .toArray();
  res.json(rows);
});

app.post('/api/masterdata', async (req, res) => {
  const doc = {
    ...req.body,
    NodeID: Number(String(req.body.NodeID).replace(/\D/g, '')),
    receivedAt: new Date(),
  };
  const r = await db().collection('masterdatas').insertOne(doc);
  res.status(201).json({ insertedId: r.insertedId });
});

/* -------------------- ALERTS -------------------- */
app.get('/api/alerts', async (req, res) => {
  const rows = await db()
    .collection('alerts')
    .find({})
    .limit(100)
    .toArray();
  res.json(rows);
});

/* -------------------- LIVE NODES -------------------- */
app.get('/api/live-nodes', async (req, res) => {
  const rows = await db()
    .collection('masterdatas')
    .find({})
    .limit(5000)
    .toArray();

  const now = Date.now();
  const seen = {};

  for (const r of rows) {
    if (!r.NodeID || !r.receivedAt) continue;
    const ts = new Date(r.receivedAt).getTime();
    if (!seen[r.NodeID] || ts > seen[r.NodeID]) {
      seen[r.NodeID] = ts;
    }
  }

  const nodes = Object.keys(seen)
    .filter(id => now - seen[id] < 15000)
    .map(id => ({
      nodeId: Number(id),
      lastSeen: new Date(seen[id]).toISOString(),
    }));

  res.json({ nodes, count: nodes.length });
});

/* -------------------- START -------------------- */
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
