-- DB 생성
CREATE SCHEMA sql_tuning DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- DB 선택
USE sql_tuning;

-- 테이블 생성
CREATE TABLE users (
   `id` INT AUTO_INCREMENT PRIMARY KEY,
   `name` VARCHAR(255),
   `age` INT
);

-- 더미 데이터 삽입 쿼리
INSERT INTO users (name, age)
WITH RECURSIVE cte (n) AS
(
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    CONCAT('User', LPAD(n, 7, '0')),   -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    FLOOR(1 + RAND() * 1000) AS age    -- 1부터 1000 사이의 랜덤 값으로 나이 생성
FROM cte;

-- 잘 생성됐는 지 확인
SELECT COUNT(id)
FROM users;

-- 인덱스 적용 전 평균 조회 시간 (execution: 150 ms, fetching: 25 ms)
SELECT *
FROM users
WHERE age = 23;

-- 인덱스 생성
CREATE INDEX idx_age ON users (age);

-- 인덱스 조회
SHOW INDEX FROM users;

-- 인덱스 적용 후 평균 조회 시간 (execution: 5 ms, fetching: 30 ms)
SELECT *
FROM users
WHERE age = 23;
