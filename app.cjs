// app.cjs — FINAL, MATCHES YOUR DATA EXACTLY

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');

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

if (!MONGO_URI) {
  console.error('❌ MONGO_URI missing');
  process.exit(1);
}

/* -------------------- DB STATE -------------------- */
let db = null;

/* -------------------- CONNECT -------------------- */
mongoose
  .connect(MONGO_URI, { dbName: DB_NAME })
  .then(() => {
    db = mongoose.connection.db;
    console.log('✅ MongoDB Atlas connected');
  })
  .catch(err => {
    console.error('❌ MongoDB error:', err.message);
  });

/* -------------------- HEALTH -------------------- */
app.get('/healthz', (req, res) => {
  res.json({
    ok: true,
    mongoConnected: !!db,
    dbName: DB_NAME,
  });
});

/* -------------------- MASTERDATA -------------------- */
app.get('/api/masterdata', async (req, res) => {
  try {
    if (!db) return res.status(503).json([]);

    const query = {};
    if (req.query.nodeId) {
      query.NodeId = Number(req.query.nodeId); // ✅ EXACT FIELD
    }

    const limit = Number(req.query.limit || 200);

    const rows = await db
      .collection('masterdatas')
      .find(query)
      .limit(limit)
      .toArray();

    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json([]);
  }
});

/* -------------------- LIVE NODES -------------------- */
app.get('/api/live-nodes', async (req, res) => {
  try {
    if (!db) return res.json({ nodes: [], count: 0 });

    const rows = await db
      .collection('masterdatas')
      .find()
      .limit(5000)
      .toArray();

    const seen = {};
    rows.forEach(r => {
      if (r.NodeId !== undefined) {
        seen[r.NodeId] = true;
      }
    });

    const nodes = Object.keys(seen).map(id => ({
      nodeId: Number(id),
    }));

    res.json({ nodes, count: nodes.length });
  } catch (e) {
    res.status(500).json({ nodes: [], count: 0 });
  }
});

/* -------------------- ALERTS -------------------- */
app.get('/api/alerts', async (req, res) => {
  if (!db) return res.json([]);
  const rows = await db.collection('alerts').find().limit(100).toArray();
  res.json(rows);
});app.get('/api/predictions/latest', async (req, res) => {
  try {
    if (!database) return res.json([]);

    const limit = Math.min(500, Number(req.query.limit || 200));

    const rows = await database
      .collection('predictions')
      .find()
      .limit(limit)
      .toArray();

    res.json(rows);
  } catch (e) {
    console.error('predictions/latest error', e);
    res.status(500).json([]);
  }
});app.get('/api/predictions/latest', async (req, res) => {
  try {
    if (!database) return res.json([]);

    const limit = Math.min(500, Number(req.query.limit || 200));

    const rows = await database
      .collection('predictions')
      .find({})
      .limit(limit)
      .toArray();

    res.json(rows);
  } catch (err) {
    console.error('predictions/latest error', err);
    res.status(500).json([]);
  }
});



/* -------------------- START -------------------- */
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
