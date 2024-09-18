DROP TABLE IF EXISTS users;

CREATE TABLE users (
   id INT AUTO_INCREMENT PRIMARY KEY,
   이름 VARCHAR(100),
   부서 VARCHAR(100),
   나이 INT
);

INSERT INTO users (이름, 부서, 나이) VALUES
('박미나', '회계', 26),
('김미현', '회계', 23),
('김민재', '회계', 21),
('이재현', '운영', 24),
('조민규', '운영', 23),
('하재원', '인사', 22),
('최지우', '인사', 22);

CREATE INDEX idx_부서_이름 ON users (부서, 이름);

SHOW INDEX FROM users;

SELECT * FROM users
WHERE 부서 = '인사'
ORDER BY 이름;