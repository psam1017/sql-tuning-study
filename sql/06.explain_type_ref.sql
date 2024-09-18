DROP TABLE IF EXISTS users; # 기존 테이블 삭제

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100)
);

INSERT INTO users (name) VALUES
('박재성'),
('김지현'),
('이지훈');

CREATE INDEX idx_name ON users(name);

EXPLAIN SELECT * FROM users WHERE name = '박재성';
