DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   department VARCHAR(100),
   salary INT,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 더미 데이터 삽입 쿼리
INSERT INTO users (name, department, salary, created_at)
WITH RECURSIVE cte (n) AS
(
   SELECT 1
   UNION ALL
   SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT
    CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
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
    FLOOR(1 + RAND() * 100000) AS salary,    -- 1부터 100000 사이의 난수로 나이 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- (execution: 708 ms, fetching: 24 ms)
-- id=1, type=ALL
-- id=1, type=eq_ref
-- id=2, type=ALL
EXPLAIN
    SELECT id, department, name, salary, created_at
    FROM users
    WHERE department IN ('Sales', 'Marketing', 'IT')
      AND (department, salary) IN (
        SELECT department, MAX(salary)
        FROM users
        WHERE department IN ('Sales', 'Marketing', 'IT')
        GROUP BY department
    );

-- 차이 없음
CREATE INDEX idx_department ON users(salary);
-- 차이 없음
CREATE INDEX idx_salary ON users(salary);

-- (execution: 4 ms, fetching: 34 ms)
-- id=1, type=ALL
-- id=1, type=eq_ref
-- id=2, type=range
CREATE INDEX idx_department_salary ON users (department, salary);