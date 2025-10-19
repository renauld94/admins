import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import fetch from 'node-fetch';
import dotenv from 'dotenv';
import pino from 'pino';

dotenv.config();

const log = pino({ level: process.env.LOG_LEVEL || 'info' });
const app = express();

const PORT = process.env.PORT || 8088;
const PROMETHEUS_BASE_URL = process.env.PROMETHEUS_BASE_URL || 'http://localhost:9090';
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);
const ALLOWED_QUERIES = (process.env.ALLOWED_QUERIES || 'up').split(',').map(s => s.trim()).filter(Boolean);

// CORS
app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);
    if (ALLOWED_ORIGINS.length === 0 || ALLOWED_ORIGINS.includes(origin)) return cb(null, true);
    cb(new Error('Not allowed by CORS'));
  },
  credentials: false
}));

// Rate limiting
const limiter = rateLimit({ windowMs: 60 * 1000, max: 60 });
app.use(limiter);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/metrics/query', async (req, res) => {
  try {
    const query = (req.query.q || '').toString();
    if (!ALLOWED_QUERIES.includes(query)) {
      return res.status(400).json({ error: 'Query not allowed' });
    }
    const url = `${PROMETHEUS_BASE_URL}/api/v1/query?query=${encodeURIComponent(query)}`;
    const r = await fetch(url, { timeout: 5000 });
    const data = await r.json();
    res.json(data);
  } catch (err) {
    log.error({ err }, 'metrics query failed');
    res.status(500).json({ error: 'Internal error' });
  }
});

app.get('/metrics/targets', async (req, res) => {
  try {
    const url = `${PROMETHEUS_BASE_URL}/api/v1/targets`;
    const r = await fetch(url, { timeout: 5000 });
    const data = await r.json();
    res.json(data);
  } catch (err) {
    log.error({ err }, 'targets query failed');
    res.status(500).json({ error: 'Internal error' });
  }
});

app.listen(PORT, () => log.info({ PORT }, 'metrics-proxy listening'));
