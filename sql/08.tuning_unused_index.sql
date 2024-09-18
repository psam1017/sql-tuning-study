DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   salary INT,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- users 테이블에 더미 데이터 삽입
INSERT INTO users (name, salary, created_at)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    FLOOR(1 + RAND() * 1000000) AS salary,    -- 1부터 1000000 사이의 난수로 급여 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

CREATE INDEX idx_name ON users (name);
CREATE INDEX idx_salary ON users (salary);

-- type=ALL
-- User000000으로 시작하는 이름을 가진 유저 조회(컬럼을 가공 O)
EXPLAIN
    SELECT *
    FROM users
    WHERE SUBSTRING(name, 1, 10) = 'User000000';

-- type=ALL
-- 2달치 급여(salary)가 1000 이하인 유저 조회(컬럼을 가공 O)
EXPLAIN
    SELECT *
    FROM users
    WHERE salary * 2 < 1000
    ORDER BY salary;

-- type=range
-- User000000으로 시작하는 이름을 가진 유저 조회(컬럼을 가공 X)
EXPLAIN
    SELECT *
    FROM users
    WHERE name LIKE 'User000000%';

-- type=range
-- 2달치 급여(salary)가 1000 이하인 유저 조회(컬럼을 가공 X)
EXPLAIN
    SELECT *
    FROM users
    WHERE salary < 1000 / 2
    ORDER BY salary;
