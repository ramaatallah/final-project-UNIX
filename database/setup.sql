CREATE DATABASE IF NOT EXISTS recommendation_db;

USE recommendation_db;

CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100),
    recommendation VARCHAR(200)
);

INSERT INTO items (keyword, recommendation) VALUES
('hot', 'Summer'),
('cold', 'Winter'),
('rain', 'Autumn'),
('wind', 'Spring'),
('snow', 'Christmas'),
('sunny', 'Beach Day'),
('cloudy', 'Stay Home');