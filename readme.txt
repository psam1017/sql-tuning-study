인프런 박재성 님의 '비전공자도 이해할 수 있는 MySQL 성능 최적화 입문/실전 (SQL 튜닝편)' 를 수강하면서 실습한 내용을 정리한 프로젝트입니다.

## 개요

DB 성능 저하 요인
1. 동시 사용자 수 증가
2. 데이터 양 증가
3. 비효율적인 SQL 작성

DB 성능 개선에 필요한 기초 개념 : 인덱스, 실행 계획, 파티셔닝, 샤닝 등

DB 성능 개선 방법
1. SQL 튜닝(최우선 개선 사항)
2. 캐싱 서버 활용
3. 레플리케이션
4. 샤딩
5. 스케일업(*스케일아웃은 수평확장, 스케일업은 수직확장)

성능 개선을 위한 MySQL 구조 파악
Client <-> MySQL Server(MySQL Engine(Optimizer) <-> Storage Engine(InnoDB))

1. 클라이언트가 DB 에 SQL 요청
2. MySQL 엔진에서 옵티마이저가 SQL 문을 분석하여 데이터를 효율적으로 조회할 수 있는 계획을 수립
- 어떤 순서로 테이블 접근
- 인덱스 사용 여부
- 어떤 인덱스를 사용할지
3. 실행 계획을 바탕으로 스토리지 엔진에서 데이터를 조회
4. MySQL 엔진에서 정렬, 필터링 등의 마지막 처리 후 클라이언트에게 결과 테이블을 응답

SQL 튜닝 핵심
1. 스토리지 엔진에서 데이터를 찾기 쉽게 바꾸기
2. 스토리지 엔진에서 가져오는 데이터 양 줄이기

## 인덱스

사전적 정의 : 데이터베이스 테이블에 대한 검색 성능의 속도를 높여주는 자료 구조
직관적 정의 : 데이터를 빨리 찾기 위해 특정 컬럼을 기준으로 미리 정렬해놓은 표

Q 나이가 23살인 모든 사용자 찾기? -> 인덱스에서 age=23 으로 시작하는 지점부터 age=24 로 시작하는 지점까지만 조회

Primary Key
- PK 에는 인덱스가 기본적으로 적용된다.
- PK 는 PK 컬럼의 값을 기준으로 데이터를 정렬하여 보관한다. 이렇게 원본 데이터 자체가 정렬되는 인덱스를 "클러스터링 인덱스(Clustering Index)"라고 한다.
- 사실, 클러스터링 인덱스는 기본키 밖에 없다.

Unique Key
- UK 에는 인덱스가 기본적으로 적용된다.
- UNIQUE 제약 조건이 부여된 컬럼은 중복 값을 허용하지 않는다. 이렇게 중복 없는 인덱스를 "고유 인덱스(Unique Index)"라고 한다.

너무 많은 인덱스
- 인덱스를 만들면 레코드를 삽입할 때마다 인덱스 테이블에도 레코드를 추가해야 한다.
- 이러한 이유로 인덱스는 Query 성능을 향상시키지만, Command 성능을 저하시킨다.
- 따라서, 인덱스는 최소한으로 사용해야 한다.

멀티 컬럼 인덱스
- 2개 이상의 컬럼을 묶어서 설정하는 인덱스
- 멀티 컬럼 인덱스의 첫 컬럼은 일반 인덱스처럼 사용할 수 있으나, 그 다음 컬럼들은 그 앞쪽 컬럼들이 정렬된 이후에 정렬되어 있기 때문에 인덱스처럼 사용할 수 없다.
  - 멀티 컬럼 인덱스 테이블을 떠올려보자.
- 멀티 컬럼 인덱스는 대분류부터 소분류 순서로 컬럼을 구성하는 게 좋다(=중복이 많은 컬럼을 앞쪽에 명시하는 게 좋다). 즉, 컬럼을 명시하는 순서는 유의미하다.
  - 단, 항상 그런 건 아니기 때문에 실행 계획과 SQL 문 실행 속도로 정확하게 측정할 필요는 있다.

# CREATE INDEX idx_부서_이름 ON users (부서, 이름);
+-----+--------+---------+
| 부서 |   이름  | id (PK) |
+-----+--------+---------+
| 운영 | 이재현  |    4    |
| 운영 | 조민규  |    5    |
| 인사 | 최지우  |    7    |
| 인사 | 하재원  |    6    |
| 회계 | 김미현  |    2    |
| 회계 | 김민재  |    3    |
| 회계 | 박미나  |    1    |
+-----+--------+---------+

커버링 인덱스
- SQL 문을 실행시킬 때 필요한 모든 컬럼을 갖고 있는 인덱스
- 만약 (name, id) 로 구성된 인덱스가 있는 상태에서, "SELECT id, name FROM users" 라는 SQL 문을 실행시킨다면 실제 테이블에 접근할 필요 없이 데이터를 모두 찾아올 수 있다.

## 실행 계획

정의 : 옵티마이저가 SQL 문을 어떤 방식으로 어떻게 처리할지 계획한 것
목표 : 실행 계획을 확인하고 비효율적인 처리를 하고 있다면 이를 개선하기

- id : 실행 순서
- table : 조회한 테이블 이름
- type : 테이블의 데이터를 어떤 방식으로 조회하는지
  - system : 시스템 테이블과 같은 매우 작은 테이블을 조회한다.
  - const : 조회하고자 하는 레코드를 정확히 일치하는 값으로 조회하는 방식이다. UK 나 PK 를 사용해서 1건의 데이터만을 찾는 아주 효율적인 방식이다.
  - eq_ref : PK 나 UK 를 사용하여 한 테이블에서 하나의 레코드를 정확히 일치하는 값으로 조회하는 방식이다. 조인된 테이블에서 각 행을 정확히 찾을 수 있음을 의미한다.
  - ref : 고유 인덱스가 아닌 인덱스를 활용한 경우이다.
  - fulltext : FULLTEXT Index 를 사용하는 방식이다. 큰 텍스트 필드에서 텍스트 기반 검색을 최적화할 수 있음을 의미한다.
  - range : Index Range Scan. 인덱스를 활용해 범위 형태의 데이터를 조회한 경우이다. BETWEEN, 비교 연산자, IN, LIKE 를 활용한 데이터 조회를 뜻한다. 인덱스를 사용하나 데이터 조회 범위가 크다면 성능 저하의 원인이 될 수도 있다.
  - index : Full Index Scan. 인덱스 테이블을 처음부터 끝까지 순회하여 데이터를 찾는 방식이다. Full Table Scan 보다는 효율적이지만 결국 인덱스 테이블 전체를 읽어야 하기 때문에 아주 효율적이라고 볼 수는 없다.
  - ALL : Full Table Scan. 인덱스를 활용하지 않고 테이블을 처음부터 끝까지 순회하여 데이터를 찾는 방식이다. 가장 비효율적이다.
- possible keys : 사용할 수 있는 인덱스 목록
- key : 데이터를 조회할 때 실제로 사용한 인덱스 값
- ref : 조인할 때 어떤 값을 기준으로 데이터를 조회했는지
- rows : SQL 문 수행을 위해 접근하는 데이터의 모든 행의 수(=데이터 액세스 수)
- filtered : 필터 조건에 따라 어느 정도의 비율로 데이터를 제거했는지
  - filtered 가 30 이라면 100 개의 데이터를 조회한 후 실제로 응답하기 위해서는 30 개의 데이터만 사용했음
  - filtered 비율이 낮을 수록 불필요한 데이터 조회가 많음을 의미
- Extra : 부가적인 정보 제공
  - Using where, Using index

* MariaDB 에서는 EXPLAIN ANALYZE 를 사용할 수 없는 것 같다...

## SQL 튜닝

WHERE 튜닝
- WHERE 문의 비교 연산자(>, <, ≤, ≥, =), IN, BETWEEN, LIKE 와 같은 곳에서 사용되는 컬럼은 인덱스를 사용했을 때 성능이 향상될 가능성이 높다.
- 데이터 액세스(rows)를 크게 줄일 수 있는 컬럼은 중복 정도가 낮은 컬럼이다. 따라서 중복 정도가 낮은 컬럼에 대해서만 인덱스를 생성하는 게 좋다.
  - WHERE 조건에 key 를 가진 컬럼들이 여러 개 있다고 해서 모든 key 가 사용되는 건 아니다.
- ’단일 컬럼에 설정하는 일반 인덱스’를 설정했을 때와 ‘멀티 컬럼 인덱스를 설정했을 때’의 성능 차이가 별로 나지 않는다면, 멀티 컬럼 인덱스를 사용하지 말고 일반 인덱스를 활용하는 게 좋다.
  - Index 는 최소화하는 게 좋다.

사용되지 않는 인덱스
- Optimizer 는 넓은 범위의 데이터를 조회할 때는 인덱스를 활용하는 것이 비효율적이라고 판단한다(실제로도 그렇다).
- 인덱스 컬럼을 가공(함수 적용, 산술 연산, 문자역 조작 등)하면, MySQL 은 해당 인덱스를 사용하지 못하는 경우가 많다.
- 따라서, 인덱스를 적극 활용하기 위해서는 인덱스 컬럼 자체를 최대한 가공하지 않아야 한다.
  - SUBSTRING(name, 1, 10) = 'USER0000000' -> name LIKE 'User000000%'
  - salary * 2 < 1000 -> salary < 1000 / 2

ORDER BY 튜닝
- ORDER BY는 시간이 오래걸리는 작업이므로 최대한 피해주는 것이 좋다. 하지만 인덱스를 사용하면 미리 정렬을 해둔 상태이기 때문에, 정렬작업을 회피할 수 있다.
- LIMIT 없이 큰 범위의 데이터를 조회해오는 경우 옵티마이저가 인덱스를 활용하지 않고 풀 테이블 스캔을 해버릴 수도 있다. 따라서 성능 효율을 위해 LIMIT을 통해 작은 데이터의 범위를 조회해오도록 항상 신경 써야 한다.

WHERE VS ORDER_BY
- 절대적인 기준은 없다. 실행계획과 SQL 실행 시간을 확인하여 비교하고 결정해야 한다.
- 하지만 ORDER BY 특징 상 모든 데이터를 바탕으로 정렬을 해야 하기 때문에, 인덱스 풀 스캔 또는 테이블 풀 스캔을 활용할 수 밖에 없다. 이 때문에 ORDER BY 보다 WHERE 에 있는 컬럼에 인덱스를 걸었을 때 성능이 향상되는 경우가 많다.

HAVING 튜닝
- HAVING 보다 우선적으로 WHERE 를 활용해야 한다.
- 단, 최근 엔진은 HAVING 에 조건이 있어도 WHERE 에 있는 것과 동일한 실행 계획을 세울 수도 있다.
- https://stackoverflow.com/questions/328636/which-sql-statement-is-faster-having-vs-where

## 실전 시나리오

1. 사용자 이름으로 특정 기간에 작성된 게시글 검색
- 사용자 이름 인덱스와 게시글 일자 인덱스를 추가한다.
- SQL 실행계획을 살펴본다.
- 사용되지 않는 인덱스를 삭제한다.

2. 부서별 최대 연봉 사용자 검색
- "부서별" "최대 연봉" 을 찾기 위해서는 먼저 부서에 접근하고, 그 다음 연봉에 접근해야 한다.
- 따라서 부서와 연봉 2가지를 정렬시켜 놓는 멀티 컬럼 인덱스를 추가한다.

3. 2024년 주문 데이터 조회
- 인덱스 주문일시에 인덱스를 추가한다.
- 단, 연도를 계산하기 위해 YEAR(ordered_at) = 2024 를 사용하지 않는다.
- 컬럼을 가공하지 않기 위해 ordered_at BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59' 를 사용한다.

4. 2024년 1학기 평균 성적이 90점 이상인 학생 조회
- 평균 성적을 구하기 위해 HAVING 을 사용할 텐데, 이때 만약 불필요한 GROUP BY 컬럼, HAVING 조건 등이 있다면 제거하고 WHERE 로 옮긴다.
- 단, 최근 엔진은 HAVING 에 조건이 있어도 WHERE 에 있는 것과 동일한 실행 계획을 세울 수도 있다.

5. 좋아요 많은 순으로 게시글 조회
- 게시글과 좋아요를 바로 조인하면 GROUP BY 할 때 조회할 레코드가 너무 많아진다.
- 서브쿼리를 사용해서 좋아요 테이블의 정보만 가져오고 조인하여 임시 테이블 및 커버링 인덱스를 활용한다.
