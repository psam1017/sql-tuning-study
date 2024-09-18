DROP TABLE IF EXISTS users; # 기존 테이블 삭제

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   account VARCHAR(100) UNIQUE
);

INSERT INTO users (account) VALUES
('user1@example.com'),
('user2@example.com'),
('user3@example.com');

EXPLAIN SELECT * FROM users WHERE id = 3;

EXPLAIN SELECT * FROM users WHERE account = 'user3@example.com';
