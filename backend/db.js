const mysql = require('mysql2');

// ─────────────────────────────────────────────────────────────────────────────
// In Docker Compose, services communicate by their SERVICE NAME, not 'localhost'.
// MYSQL_HOST defaults to 'db'  (the name defined in docker-compose.yml).
// All sensitive values are read from environment variables injected by Docker.
// ─────────────────────────────────────────────────────────────────────────────
const connection = mysql.createConnection({
    host:     process.env.MYSQL_HOST     || 'db',
    port:     process.env.MYSQL_PORT     || 3306,
    user:     process.env.MYSQL_USER     || 'root',
    password: process.env.MYSQL_PASSWORD || '',
    database: process.env.MYSQL_DATABASE || 'recommendation_db'
});

connection.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        process.exit(1); // Exit so Docker can restart the container
    }
    console.log('Connected to MySQL ✅');
});

module.exports = connection;