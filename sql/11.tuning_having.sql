# noinspection SqlAggregatesForFile

DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   age INT,
   department VARCHAR(100),
   salary INT,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 더미 데이터 삽입 쿼리
INSERT INTO users (name, age, department, salary, created_at)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    FLOOR(1 + RAND() * 100) AS age, -- 1부터 100 사이의 난수로 생성
    CASE
        WHEN n % 10 = 1 THEN 'Engineering'
        WHEN n % 10 = 2 THEN 'Marketing'
        WHEN n % 10 = 3 THEN 'Sales'
        WHEN n % 10 = 4 THEN 'Finance'
        WHEN n % 10 = 5 THEN 'HR'
        WHEN n % 10 = 6 THEN 'Operations'
        WHEN n % 10 = 7 THEN 'IT'
        WHEN n % 10 = 8 THEN 'Customer Service'
        WHEN n % 10 = 9 THEN 'Research and Development'
        ELSE 'Product Management'
        END AS department,  -- 의미 있는 단어 조합으로 부서 이름 생성
    FLOOR(1 + RAND() * 1000000) AS salary,    -- 1부터 1000000 사이의 난수로 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

CREATE INDEX idx_age ON users (age);

-- case1. type=index -> Optimizer 가 SQL 문을 그대로 실행한 경우
-- case2. type=range -> Optimizer 가 SQL 문을 WHERE 에서 실행할 때처럼 자동으로 수정한 경우. 최신 MySQL 엔진은 자동으로 SQL 을 튜닝하기도 한다.
EXPLAIN
    SELECT age, MAX(salary)
    FROM users
    GROUP BY age
    HAVING age >= 20
       AND age < 30;

-- type=range
EXPLAIN
    SELECT age, MAX(salary)
    FROM users
    WHERE age >= 20
      AND age < 30
    GROUP BY age;
