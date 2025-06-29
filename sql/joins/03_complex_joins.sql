-- SQL JOIN編: 実践的な結合パターン
-- ==============================
-- 目的: 複数テーブルの結合、サブクエリとの組み合わせなどを学習

-- 1. 4つのテーブルを結合
-- 生徒、クラス、成績、教科の完全な情報を取得
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    c.grade,
    sub.subject_name,
    sc.score,
    e.exam_name,
    e.exam_date
FROM workshop.students s
INNER JOIN workshop.classes c 
    ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
LEFT JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
LEFT JOIN workshop.exams e 
    ON sc.exam_id = e.exam_id
WHERE c.grade = 1  -- 1年生のみ
  AND e.exam_number = 1  -- 1学期中間テスト
ORDER BY c.class_name, s.student_id, sub.subject_id;

-- 2. サブクエリを使った結合
-- クラスごとの平均点と各生徒の成績を比較
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    sc.score,
    c.class_name,
    class_avg.avg_score AS class_avg_score,
    sc.score - class_avg.avg_score AS score_diff,
    CASE 
        WHEN sc.score > class_avg.avg_score THEN '平均以上'
        WHEN sc.score = class_avg.avg_score THEN '平均'
        ELSE '平均以下'
    END AS score_level
FROM workshop.students s
INNER JOIN workshop.classes c 
    ON s.class_id = c.class_id
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN (
    SELECT 
        s2.class_id,
        sc2.subject_id,
        sc2.exam_id,
        AVG(sc2.score) AS avg_score
    FROM workshop.students s2
    INNER JOIN workshop.scores sc2 
        ON s2.student_id = sc2.student_id
    WHERE sc2.score IS NOT NULL
    GROUP BY s2.class_id, sc2.subject_id, sc2.exam_id
) class_avg 
    ON s.class_id = class_avg.class_id
    AND sc.subject_id = class_avg.subject_id
    AND sc.exam_id = class_avg.exam_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
  AND sc.subject_id = 2  -- 数学
  AND sc.score IS NOT NULL
ORDER BY c.class_name, score_diff DESC;

-- 3. WITH句（CTE）を使った複雑な結合
-- 学年ごとの成績分布と上位者
WITH grade_stats AS (
    SELECT 
        c.grade,
        sub.subject_name,
        COUNT(sc.score) AS student_count,
        AVG(sc.score) AS avg_score,
        STDDEV(sc.score) AS std_dev
    FROM workshop.classes c
    INNER JOIN workshop.students s 
        ON c.class_id = s.class_id
    INNER JOIN workshop.scores sc 
        ON s.student_id = sc.student_id
    INNER JOIN workshop.subjects sub 
        ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1  -- 1学期中間テスト
      AND sc.score IS NOT NULL
    GROUP BY c.grade, sub.subject_name
),
top_students AS (
    SELECT 
        c.grade,
        sub.subject_name,
        s.last_name || ' ' || s.first_name AS student_name,
        sc.score,
        RANK() OVER (PARTITION BY c.grade, sub.subject_name ORDER BY sc.score DESC) AS rank
    FROM workshop.classes c
    INNER JOIN workshop.students s 
        ON c.class_id = s.class_id
    INNER JOIN workshop.scores sc 
        ON s.student_id = sc.student_id
    INNER JOIN workshop.subjects sub 
        ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1  -- 1学期中間テスト
      AND sc.score IS NOT NULL
)
SELECT 
    gs.grade,
    gs.subject_name,
    gs.avg_score,
    gs.std_dev,
    ts.student_name AS top_student,
    ts.score AS top_score
FROM grade_stats gs
LEFT JOIN top_students ts 
    ON gs.grade = ts.grade 
    AND gs.subject_name = ts.subject_name
    AND ts.rank = 1
ORDER BY gs.grade, gs.subject_name;

-- 4. 自己結合の応用
-- 同じテストで同点を取った生徒のペア
SELECT DISTINCT
    s1.last_name || ' ' || s1.first_name AS student1,
    s2.last_name || ' ' || s2.first_name AS student2,
    sub.subject_name,
    sc1.score,
    e.exam_name
FROM workshop.scores sc1
INNER JOIN workshop.scores sc2 
    ON sc1.subject_id = sc2.subject_id 
    AND sc1.exam_id = sc2.exam_id
    AND sc1.score = sc2.score
    AND sc1.student_id < sc2.student_id
INNER JOIN workshop.students s1 
    ON sc1.student_id = s1.student_id
INNER JOIN workshop.students s2 
    ON sc2.student_id = s2.student_id
INNER JOIN workshop.subjects sub 
    ON sc1.subject_id = sub.subject_id
INNER JOIN workshop.exams e 
    ON sc1.exam_id = e.exam_id
WHERE sc1.score IS NOT NULL
  AND sc1.score >= 90  -- 90点以上の高得点のみ
ORDER BY e.exam_name, sub.subject_name, sc1.score DESC;

-- 5. 結合を使った成績推移分析
-- 生徒ごとの成績推移（科目別）
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    MAX(CASE WHEN e.exam_number = 1 THEN sc.score END) AS exam1,
    MAX(CASE WHEN e.exam_number = 2 THEN sc.score END) AS exam2,
    MAX(CASE WHEN e.exam_number = 3 THEN sc.score END) AS exam3,
    MAX(CASE WHEN e.exam_number = 4 THEN sc.score END) AS exam4,
    MAX(CASE WHEN e.exam_number = 5 THEN sc.score END) AS exam5,
    AVG(sc.score) AS avg_score
FROM workshop.students s
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
INNER JOIN workshop.exams e 
    ON sc.exam_id = e.exam_id
WHERE s.student_id IN (1, 2, 3, 4, 5)  -- 特定の生徒のみ
  AND sc.score IS NOT NULL
GROUP BY s.student_id, s.last_name, s.first_name, sub.subject_name
ORDER BY s.student_id, sub.subject_name;

-- 6. 結合を使ったデータ検証
-- 不整合データの検出（成績があるが生徒情報がない、存在しない教科IDなど）
SELECT 
    '生徒情報がない成績データ' AS issue_type,
    sc.score_id,
    sc.student_id,
    sc.subject_id,
    sc.exam_id,
    sc.score
FROM workshop.scores sc
LEFT JOIN workshop.students s 
    ON sc.student_id = s.student_id
WHERE s.student_id IS NULL

UNION ALL

SELECT 
    '存在しない教科の成績' AS issue_type,
    sc.score_id,
    sc.student_id,
    sc.subject_id,
    sc.exam_id,
    sc.score
FROM workshop.scores sc
LEFT JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE sub.subject_id IS NULL

UNION ALL

SELECT 
    '存在しないテストの成績' AS issue_type,
    sc.score_id,
    sc.student_id,
    sc.subject_id,
    sc.exam_id,
    sc.score
FROM workshop.scores sc
LEFT JOIN workshop.exams e 
    ON sc.exam_id = e.exam_id
WHERE e.exam_id IS NULL;

-- 7. 動的な結合条件
-- 成績レンジに基づいて生徒をグループ化
WITH score_ranges AS (
    SELECT 
        1 AS range_id, 
        '90点以上' AS range_name, 
        90 AS min_score, 
        100 AS max_score
    UNION ALL
    SELECT 2, '80-89点', 80, 89
    UNION ALL
    SELECT 3, '70-79点', 70, 79
    UNION ALL
    SELECT 4, '60-69点', 60, 69
    UNION ALL
    SELECT 5, '60点未満', 0, 59
)
SELECT 
    sr.range_name,
    sub.subject_name,
    COUNT(sc.score_id) AS student_count,
    ROUND(COUNT(sc.score_id) * 100.0 / 
        (SELECT COUNT(*) FROM workshop.scores sc2 
         WHERE sc2.exam_id = 1 
           AND sc2.subject_id = sub.subject_id 
           AND sc2.score IS NOT NULL), 1) AS percentage
FROM score_ranges sr
CROSS JOIN workshop.subjects sub
LEFT JOIN workshop.scores sc 
    ON sc.score >= sr.min_score 
    AND sc.score <= sr.max_score
    AND sc.subject_id = sub.subject_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.score IS NOT NULL
GROUP BY sr.range_id, sr.range_name, sub.subject_id, sub.subject_name
ORDER BY sub.subject_id, sr.range_id;