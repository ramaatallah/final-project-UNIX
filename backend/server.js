const express = require('express');
const cors = require('cors');
const path = require('path');
const db = require('./db');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());  

/* ✅ FIX: serving frontend from project root */
app.use(express.static(path.join(__dirname, '..', 'frontend')));

/* Route: recommendation API */
app.get('/recommend', (req, res) => {
    const keyword = req.query.input;

    if (!keyword) {
        return res.json({ recommendation: 'Please enter a keyword!' });
    }

    const query = 'SELECT recommendation FROM items WHERE keyword = ?';

    db.query(query, [keyword.toLowerCase()], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (results.length === 0) {
            return res.json({ recommendation: 'No recommendation found!' });
        }

        res.json({ recommendation: results[0].recommendation });
    });
});

/* Start server */
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT} 🚀`);
});