// app.cjs
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const axios = require('axios');

const app = express();
app.use(express.json({ limit: '20mb' }));
app.use(cors());
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));

const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nwarehouse';
const ML_BASE = process.env.ML_BASE || 'http://10.100.75.165:5000';

const MAX_CONNECT_RETRIES = Number(process.env.MAX_CONNECT_RETRIES || 10);
const RETRY_DELAY_MS = Number(process.env.RETRY_DELAY_MS || 5000);

let mongoConnected = false;
let database = null;
let connectAttempts = 0;

function cleanNodeId(raw) {
  if (raw === undefined || raw === null) return null;
  const s = String(raw);
  // If it's already a clean integer string like "2101" -> return that
  if (/^\d+$/.test(s)) return Number(s);
  // Extract all digit groups and join them
  const digits = s.match(/\d+/g);
  if (!digits) return null;
  const joined = digits.join('');
  // If joined is empty or not numeric -> null
  if (!/^\d+$/.test(joined)) return null;
  // trim leading zeros to avoid weird long numbers if you prefer:
  // return Number(joined.replace(/^0+/, '') || '0');
  return Number(joined);
}

async function connectWithRetry() {
  while (!mongoConnected && connectAttempts < MAX_CONNECT_RETRIES) {
    try {
      connectAttempts += 1;
      await mongoose.connect(MONGO_URI, { dbName: 'nwarehouse' });
      database = mongoose.connection.db;
      mongoConnected = true;
      console.log('✅ MongoDB connected');
      await ensureCollectionsExist();
      // perform an initial nodehealth refresh and prediction refresh safely
      try { await initialRefresh(); } catch (e) {}
      break;
    } catch (err) {
      console.error(`Mongo connect attempt ${connectAttempts} failed:`, err.message || err);
      if (connectAttempts >= MAX_CONNECT_RETRIES) {
        console.error('Max Mongo connect attempts reached; continuing without DB.');
        break;
      }
      await new Promise((res) => setTimeout(res, RETRY_DELAY_MS));
    }
  }
}

async function ensureCollectionsExist() {
  if (!database) return;
  const required = ['warehouses','alerts','masterdatas','nodehealth','reports','predictions','thresholds','auditlogs'];
  try {
    const existing = (await database.listCollections().toArray()).map((c) => c.name);
    for (const name of required) {
      if (!existing.includes(name)) {
        try { await database.createCollection(name); console.log(`Created collection: ${name}`); } catch(e){}
      }
    }
    try {
      await database.collection('masterdatas').createIndex({ NodeID: 1 });
      await database.collection('predictions').createIndex({ nodeId: 1 });
      await database.collection('alerts').createIndex({ nodeId: 1 });
      await database.collection('nodehealth').createIndex({ NodeID: 1 });
    } catch(e){}
  } catch (e) {
    console.error('ensureCollectionsExist failed:', e.message || e);
  }
}

async function initialRefresh() {
  try {
    // rebuild nodehealth from masterdatas
    if (!database) return;
    const masterRows = await database.collection('masterdatas').find().toArray();
    if (masterRows.length === 0) return;
    const map = {};
    for (const r of masterRows) {
      const idRaw = r.NodeID ?? r.nodeId ?? null;
      const id = cleanNodeId(idRaw);
      const key = id === null ? 'unknown' : id;
      if (!map[key]) map[key] = { NodeID: key, readingCount: 0, uptimeSec: r.Uptime_sec || 0 };
      map[key].readingCount++;
      if (r.Uptime_sec) map[key].uptimeSec = r.Uptime_sec;
    }
    const arr = Object.keys(map).map(k => ({ ...map[k], updatedAt: new Date() }));
    if (arr.length > 0) {
      await database.collection('nodehealth').deleteMany({});
      await database.collection('nodehealth').insertMany(arr);
      console.log('nodehealth initial refresh complete:', arr.length);
    }

    // optional: initial predictions refresh (latest per node)
    // We'll create one heuristic prediction per distinct node using last reading
    const latestByNode = {};
    for (const r of masterRows) {
      const id = cleanNodeId(r.NodeID ?? r.nodeId);
      const key = id === null ? 'unknown' : id;
      // choose latest by Timestamp string (not perfect) — if Timestamp missing, keep first
      if (!latestByNode[key]) latestByNode[key] = r;
      else {
        const prev = latestByNode[key];
        try {
          const a = new Date(String(r.Timestamp));
          const b = new Date(String(prev.Timestamp));
          if (!isNaN(a.getTime()) && a > b) latestByNode[key] = r;
        } catch (e) {}
      }
    }
    const preds = [];
    for (const k of Object.keys(latestByNode)) {
      const row = latestByNode[k];
      const t1 = Number(row.TGS2620 || row.tgs2620 || 0);
      const t2 = Number(row.TGS2602 || row.tgs2602 || 0);
      const t3 = Number(row.TGS2600 || row.tgs2600 || 0);
      // simple heuristic: weighted sum normalized
      const denom = Math.max(t1, t2, t3, 1);
      const raw = (0.4 * (t1/denom) + 0.3 * (t2/denom) + 0.3 * (t3/denom));
      const riskScore = Math.round(Math.min(100, Math.max(0, raw * 100)) * 10000) / 10000;
      const status = riskScore > 50 ? 'High' : riskScore > 20 ? 'Medium' : 'Healthy';
      preds.push({
        nodeId: k === 'unknown' ? null : k,
        tgs2620: t1,
        tgs2602: t2,
        tgs2600: t3,
        timestamp: row.Timestamp || new Date().toISOString(),
        riskScore,
        status,
        modelUsed: 'heuristic',
        createdAt: new Date()
      });
    }
    if (preds.length > 0) {
      await database.collection('predictions').deleteMany({});
      await database.collection('predictions').insertMany(preds);
      console.log('predictions initial refresh complete:', preds.length);
    }
  } catch (e) {
    console.error('initialRefresh failed:', e.message || e);
  }
}

connectWithRetry();

function getDb() {
  if (mongoConnected && database) return database;
  return null;
}

/* --------------------- BASIC ---------------------- */
app.get('/healthz', (req, res) => {
  res.json({ ok: true, mongoConnected, connectAttempts, env: { MONGO_URI: !!process.env.MONGO_URI, ML_BASE } });
});

/* --------------------- WAREHOUSES ---------------------- */
app.get('/api/warehouses', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.json([]);
    const rows = await db.collection('warehouses').find().toArray();
    return res.json(rows);
  } catch (e) { console.error('/api/warehouses', e); return res.status(500).json({ error: 'Failed' }); }
});

app.post('/api/warehouses', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.status(503).json({ error: 'DB not available' });
    const r = await db.collection('warehouses').insertOne({ ...req.body, createdAt: new Date() });
    return res.status(201).json({ insertedId: r.insertedId });
  } catch (e) { console.error('/api/warehouses POST', e); return res.status(500).json({ error: 'Failed' }); }
});

/* --------------------- ALERTS ---------------------- */
app.get('/api/alerts', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.json([]);
    const rows = await db.collection('alerts').find().sort({ timestamp: -1 }).toArray();
    return res.json(rows);
  } catch (e) { console.error('/api/alerts', e); return res.status(500).json({ error: 'Failed' }); }
});

app.post('/api/alerts', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.status(503).json({ error: 'DB not available' });
    const payload = { ...req.body, nodeId: cleanNodeId(req.body.nodeId ?? req.body.NodeID) ?? req.body.nodeId ?? req.body.NodeID, timestamp: req.body.timestamp ? new Date(req.body.timestamp) : new Date() };
    const r = await db.collection('alerts').insertOne(payload);
    return res.status(201).json({ insertedId: r.insertedId });
  } catch (e) { console.error('/api/alerts POST', e); return res.status(500).json({ error: 'Failed' }); }
});

/* --------------------- MASTER DATA ---------------------- */
app.get('/api/masterdata', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.json([]);
    const query = {};
    if (req.query.nodeId) {
      const nid = cleanNodeId(req.query.nodeId);
      if (nid !== null) query.NodeID = nid;
    }
    const rows = await db.collection('masterdatas').find(query).sort({ Timestamp: -1 }).limit(500).toArray();
    return res.json(rows);
  } catch (e) { console.error('/api/masterdata', e); return res.status(500).json({ error: 'Failed' }); }
});

app.post('/api/masterdata', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.status(503).json({ error: 'DB not available' });

    if (Array.isArray(req.body)) {
      const docs = req.body.map(d => {
        const fixedId = cleanNodeId(d.NodeID ?? d.nodeId);
        return { ...d, NodeID: fixedId, receivedAt: new Date() };
      });
      const r = await db.collection('masterdatas').insertMany(docs);
      return res.status(201).json({ insertedCount: r.insertedCount });
    } else {
      const fixedId = cleanNodeId(req.body.NodeID ?? req.body.nodeId);
      const doc = { ...req.body, NodeID: fixedId, receivedAt: new Date() };
      const r = await db.collection('masterdatas').insertOne(doc);
      return res.status(201).json({ insertedId: r.insertedId });
    }
  } catch (e) { console.error('/api/masterdata POST', e); return res.status(500).json({ error: 'Failed' }); }
});

/* --------------------- NODE HEALTH ---------------------- */
app.get('/api/nodehealth', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.json([]);
    const rows = await db.collection('nodehealth').find().toArray();
    return res.json(rows);
  } catch (e) { console.error('/api/nodehealth', e); return res.status(500).json({ error: 'Failed' }); }
});

app.post('/api/nodehealth/refresh', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.status(503).json({ error: 'DB not available' });
    const masterRows = await db.collection('masterdatas').find().toArray();
    const map = {};
    for (const r of masterRows) {
      const id = cleanNodeId(r.NodeID ?? r.nodeId);
      const key = id === null ? 'unknown' : id;
      if (!map[key]) map[key] = { NodeID: key, readingCount: 0, uptimeSec: r.Uptime_sec || 0 };
      map[key].readingCount++;
      if (r.Uptime_sec) map[key].uptimeSec = r.Uptime_sec;
    }
    const arr = Object.keys(map).map(k => ({ ...map[k], updatedAt: new Date() }));
    await db.collection('nodehealth').deleteMany({});
    if (arr.length > 0) await db.collection('nodehealth').insertMany(arr);
    return res.json({ updated: arr.length });
  } catch (e) { console.error('/api/nodehealth/refresh', e); return res.status(500).json({ error: 'Failed' }); }
});

/* --------------------- REPORTS ---------------------- */
app.get('/api/reports', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.json([]);
    const rows = await db.collection('reports').find().sort({ createdAt: -1 }).toArray();
    return res.json(rows);
  } catch (e) { console.error('/api/reports', e); return res.status(500).json({ error: 'Failed' }); }
});

app.post('/api/reports/generate', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.status(503).json({ error: 'DB not available' });
    const masterRows = await db.collection('masterdatas').find().toArray();
    const report = {
      createdAt: new Date(),
      type: req.body.type || 'AutoReport',
      summary: { totalReadings: masterRows.length, totalNodes: new Set(masterRows.map((r) => cleanNodeId(r.NodeID ?? r.nodeId))).size }
    };
    const r = await db.collection('reports').insertOne(report);
    return res.status(201).json({ reportId: r.insertedId, summary: report.summary });
  } catch (e) { console.error('/api/reports/generate', e); return res.status(500).json({ error: 'Failed' }); }
});

/* --------------------- PREDICTIONS ---------------------- */
app.get('/api/predictions/latest', async (req, res) => {
  const db = getDb();
  try {
    if (!db) return res.json([]);
    const rows = await db.collection('predictions').find().sort({ timestamp: -1 }).limit(500).toArray();
    return res.json(rows);
  } catch (e) { console.error('/api/predictions/latest', e); return res.status(500).json({ error: 'Failed' }); }
});

// Predict route: forwards to ML service; store cleaned nodeId in DB
app.post('/api/predictions/predict', async (req, res) => {
  try {
    const mlResponse = await axios.post(`${ML_BASE}/predict`, req.body, { headers: { 'Content-Type': 'application/json' }, timeout: 15000 });
    const db = getDb();
    const nodeIdClean = cleanNodeId(req.body.nodeId ?? req.body.NodeID);
    const payload = Object.assign({}, mlResponse.data, {
      nodeId: nodeIdClean,
      timestamp: mlResponse.data.timestamp ? mlResponse.data.timestamp : new Date().toISOString(),
      createdAt: new Date()
    });
    if (db) {
      try { await db.collection('predictions').insertOne(payload); } catch(e){ console.error('store prediction failed', e); }
    }
    return res.json(mlResponse.data);
  } catch (e) {
    console.error('/api/predictions/predict error', e.message || e);
    return res.status(502).json({ error: 'ML service failed', detail: e.message || String(e) });
  }
});

/* --------------------- FALLBACK ---------------------- */
app.use((req, res) => res.status(404).json({ error: 'Not Found' }));

app.use((err, req, res, next) => { console.error('Unhandled error', err); res.status(500).json({ error: 'Server Error' }); });

setInterval(async () => {
  if (!mongoConnected) {
    console.log('Mongo not connected — attempting reconnect...');
    try { await connectWithRetry(); } catch (e) {}
  } else {
    try { await ensureCollectionsExist(); } catch (e) {}
  }
}, 15000);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${PORT} (ML: ${ML_BASE})`);
});
