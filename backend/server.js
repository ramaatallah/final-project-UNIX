const express = require('express');
const cors = require('cors');
const path = require('path');
const db = require('./db');

const app = express();
const PORT = 3000;

/* Middleware */
app.use(cors());
app.use(express.json());  

/* Serve frontend (if exists) */
app.use(express.static(path.join(__dirname, '..', 'frontend')));

/* Root route */
app.get('/', (req, res) => {
    res.send('Backend is running 🚀');
});

/* Health check (مهم لـ Jenkins و Docker) */
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Server is healthy 🚀'
    });
});

/* Recommendation API */
app.get('/recommend', (req, res) => {
    const keyword = req.query.input;

    if (!keyword) {
        return res.status(400).json({
            recommendation: 'Please enter a keyword!'
        });
    }

    const query = 'SELECT recommendation FROM items WHERE keyword = ?';

    db.query(query, [keyword.toLowerCase()], (err, results) => {
        if (err) {
            console.error('DB Error:', err);
            return res.status(500).json({ error: 'Database error' });
        }

        if (results.length === 0) {
            return res.json({
                recommendation: 'No recommendation found!'
            });
        }

        res.json({
            recommendation: results[0].recommendation
        });
    });
});

/* Start server */
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT} 🚀`);
});