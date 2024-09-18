use sql_tuning;

DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS posts;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
   id INT AUTO_INCREMENT PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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

-- posts 테이블에 더미 데이터 삽입
INSERT INTO posts (title, created_at, user_id)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    CONCAT('Post', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at, -- 최근 10년 내의 임의의 날짜와 시간 생성
    FLOOR(1 + RAND() * 50000) AS user_id -- 1부터 50000 사이의 난수로 급여 생성
FROM cte;

-- type=ALL (execution: 780 ms, fetching: 25 ms)
EXPLAIN
    SELECT p.*
    FROM posts p
             JOIN users u
                  ON p.user_id = u.id
    WHERE u.name = 'User0000046'
      AND p.created_at BETWEEN '2024-01-01' AND '2024-12-31';

-- type=range (execution: 495 ms, fetching: 22 ms)
CREATE INDEX idx_post_created_at ON posts(created_at);

-- type=ref (execution: 3 ms, fetching: 33 ms)
CREATE INDEX idx_user_name ON users(name);