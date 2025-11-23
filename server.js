require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const bcrypt = require('bcrypt');

// ==== Config ====
const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://10.150.216.165:27017/nwarehouse';
const NODE_ENV = process.env.NODE_ENV || 'development';

// ==== Express App ====
const app = express();

// ==== Middleware ====
app.use(helmet());
app.use(compression());
app.use(cors({ origin: '*', methods: ['GET','POST','PUT','DELETE'], allowedHeaders: ['Content-Type','Authorization'] }));
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

// ==== MongoDB Connection ====
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
.then(async () => {
    console.log('✅ MongoDB connected');

    const masterDataCol = mongoose.connection.db.collection('masterdatas');
    const predictionCol = mongoose.connection.db.collection('predictions');

    listCollections();

    runMLLoop(masterDataCol, predictionCol); // start ML prediction loop
})
.catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
});

// ==== Helper: List collections ====
async function listCollections() {
    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    console.log('Collections in DB:', collections.map(c => c.name));
}

// ==== User Schema ====
const userSchema = new mongoose.Schema({
    name: String,
    email: { type: String, unique: true },
    password: String,
});
const User = mongoose.model('User', userSchema);

// ==== Auth Routes ====
const authRouter = express.Router();

// Register
authRouter.post('/register', async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const hashed = await bcrypt.hash(password, 10);
        const user = new User({ name, email, password: hashed });
        await user.save();
        res.status(201).json({ message: 'User registered' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Login
authRouter.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email });
        if (!user) return res.status(404).json({ error: 'User not found' });
        const match = await bcrypt.compare(password, user.password);
        if (!match) return res.status(401).json({ error: 'Invalid password' });
        res.json({ message: 'Login successful', userId: user._id, name: user.name });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==== Public Routes ====
app.get('/healthz', (req, res) => res.json({ ok: true, uptime: process.uptime() }));

// Masterdata API
app.get('/api/masterdata', async (req, res) => {
    try {
        const data = await mongoose.connection.db.collection('masterdatas').find().toArray();
        res.json(data);
    } catch (err) {
        console.error('API fetch error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Predictions API
app.get('/api/predictions', async (req, res) => {
    try {
        const data = await mongoose.connection.db.collection('predictions').find().toArray();
        res.json(data);
    } catch (err) {
        console.error('API fetch error:', err);
        res.status(500).json({ error: err.message });
    }
});

// ==== Apply Auth Routes ====
app.use('/api/auth', rateLimit({ windowMs: 15*60*1000, max: 100 }), authRouter);

// ==== Static Client (Optional) ====
if (NODE_ENV === 'production') {
    app.use(express.static(path.join(__dirname, '../client/build')));
    app.get('*', (req, res) => 
        res.sendFile(path.join(__dirname, '../client/build', 'index.html'))
    );
}

// ==== Error Handling ====
app.use((req, res, next) => res.status(404).json({ error: 'Not Found' }));
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Server Error' });
});

// ==== Start Server ====
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running at http://10.150.216.165:${PORT}`);
});

// ==== ML Prediction Loop every 15s ====
function predictRisk(data) {
    // Mock regression-based probability
    const score = 0.4*data.TGS2620 + 0.3*data.TGS2602 + 0.3*data.TGS2600;
    return Math.min(Math.max(score, 0), 100); // Clamp 0-100
}

async function runMLLoop(masterDataCol, predictionCol) {
    setInterval(async () => {
        try {
            const data = await masterDataCol.find().toArray();
            if (!data || data.length === 0) return;

            const predictions = data.map(d => {
                const riskScore = predictRisk(d);
                return {
                    nodeId: d.NodeID,
                    tgs2620: d.TGS2620,
                    tgs2602: d.TGS2602,
                    tgs2600: d.TGS2600,
                    timestamp: d.Timestamp,
                    riskScore,
                    status: riskScore > 50 ? 'High' : riskScore > 20 ? 'Medium' : 'Low'
                };
            });

            await predictionCol.deleteMany({}); // optional: keep only latest
            await predictionCol.insertMany(predictions);

            console.log('🔹 Predictions updated:', new Date().toLocaleTimeString());
        } catch (err) {
            console.error('ML Loop Error:', err);
        }
    }, 15000);
}
