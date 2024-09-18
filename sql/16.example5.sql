DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS posts;

CREATE TABLE posts (
   id INT AUTO_INCREMENT PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE likes (
   id INT AUTO_INCREMENT PRIMARY KEY,
   post_id INT,
   user_id INT,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY (post_id) REFERENCES posts(id),
   FOREIGN KEY (user_id) REFERENCES users(id)
);

-- posts 테이블에 더미 데이터 삽입
INSERT INTO posts (title, created_at)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    CONCAT('Post', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

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

-- likes 테이블에 더미 데이터 삽입
INSERT INTO likes (post_id, user_id, created_at)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    FLOOR(1 + RAND() * 1000000) AS post_id,    -- 1부터 1000000 사이의 난수로 급여 생성
    FLOOR(1 + RAND() * 1000000) AS user_id,    -- 1부터 1000000 사이의 난수로 급여 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- (execution: 2 s 315 ms, fetching: 19 ms) 조인한 모든 레코드를 대상으로 GROUP BY 실행
-- id=1, type=range
-- id=2, type=eq_ref
    EXPLAIN
    SELECT
        p.id,
        p.title,
        p.created_at,
        COUNT(l.id) AS like_count
    FROM posts p
    JOIN likes l
        ON p.id = l.post_id
    GROUP BY p.id
    ORDER BY like_count DESC
    LIMIT 30;

-- (execution: 10 ms, fetching: 48 ms) 커버링 인덱스 활용
-- id=1, type=ALL
-- id=1, type=ref
-- id=2, type=ref
EXPLAIN
    SELECT
        p.id,
        p.title,
        p.created_at,
        l.like_count
    FROM posts p
    JOIN (
        SELECT l.post_id, count(l.post_id) AS like_count
        FROM likes l
        GROUP BY l.post_id
        ORDER BY like_count DESC
        LIMIT 30
    ) l ON p.id = l.post_id;