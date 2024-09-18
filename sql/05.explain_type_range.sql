DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   age INT
);

-- 더미 데이터 삽입 쿼리
INSERT INTO users (age)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    FLOOR(1 + RAND() * 1000) AS age    -- 1부터 1000 사이의 난수로 나이 생성
FROM cte;

CREATE INDEX idx_age ON users(age);

EXPLAIN
    SELECT *
    FROM users
    WHERE age BETWEEN 10 and 20;

EXPLAIN
    SELECT *
    FROM users
    WHERE age IN (10, 20, 30);

EXPLAIN
    SELECT *
    FROM users
    WHERE age < 20;