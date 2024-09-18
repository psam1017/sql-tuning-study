DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100),
   department VARCHAR(100),
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 더미 데이터 삽입 쿼리
INSERT INTO users (name, department, created_at)
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
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- Index 생성 전 type=ALL
-- Index 생성 후 type=range
EXPLAIN
    SELECT *
    FROM users
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY);

-- created_at 에 Index 생성
CREATE INDEX idx_created_at ON users (created_at);

-- Index 생성 전 type=ALL
-- idx_department 생성 시 case1. type=ALL -> possible_keys 는 있으나, 비효율적이라 판단하여 Full Table Scan 수행.
-- idx_department 생성 시 case2. type=ref -> 비고유 인덱스로 찾지만, rows 가 수만 건 이상이어서 여전히 비효율적이다.
-- idx_created_at 생성 시 type=range -> 범위 탐색을 하지만, 중복이 적은 컬럼으로 찾기에 rows 가 수천 건 이하여서 idx_department 보다 효율적이다.
-- idx_department_created_at 생성 시 type=range -> idx_created_at 보다 효율적인 건 맞지만 유의미한 차이가 없다.
EXPLAIN
    SELECT *
    FROM users
    WHERE department = 'Sales'
      AND created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY);

-- department, created_at 에 대하여 다양한 Index 생성
CREATE INDEX idx_department ON users (department);
CREATE INDEX idx_created_at ON users (created_at);
CREATE INDEX idx_department_created_at ON users (department, created_at);
