DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS orders;

CREATE TABLE users (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       name VARCHAR(100),
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        user_id INT,
                        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- users 테이블에 더미 데이터 삽입
INSERT INTO users (name, created_at)
WITH RECURSIVE cte (n) AS
                   (
                       SELECT 1
                       UNION ALL
                       SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
                   )
SELECT
    CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- orders 테이블에 더미 데이터 삽입
INSERT INTO orders (ordered_at, user_id)
WITH RECURSIVE cte (n) AS
                   (
                       SELECT 1
                       UNION ALL
                       SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
                   )
SELECT
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS ordered_at, -- 최근 10년 내의 임의의 날짜와 시간 생성
    FLOOR(1 + RAND() * 1000000) AS user_id    -- 1부터 1000000 사이의 난수로 급여 생성
FROM cte;

CREATE INDEX idx_ordered_at ON orders (ordered_at);

-- (execution: 2 s 545 ms, fetching: 19 ms)
-- type=index
EXPLAIN
SELECT *
FROM orders
WHERE YEAR(ordered_at) = 2023
ORDER BY ordered_at
LIMIT 30;

-- (execution: 10 ms, fetching: 30 ms)
-- type=range
EXPLAIN
SELECT *
FROM orders
WHERE ordered_at >= '2023-01-01 00:00:00'
  AND ordered_at < '2024-01-01 00:00:00'
ORDER BY ordered_at
LIMIT 30;
