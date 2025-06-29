-- SQL GROUP BY編: 高度なGROUP BY
-- ===============================
-- 目的: ROLLUP、CUBE、GROUPING SETS、ウィンドウ関数などの高度な機能を学習

-- 1. GROUPING SETS
-- 複数の異なるグループ化を一度に実行
SELECT 
    c.grade,
    c.class_name,
    sub.subject_name,
    AVG(sc.score) AS avg_score,
    COUNT(sc.score) AS score_count
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
GROUP BY GROUPING SETS (
    (c.grade, c.class_name, sub.subject_name),  -- クラス・科目別
    (c.grade, sub.subject_name),                 -- 学年・科目別
    (sub.subject_name),                          -- 科目別全体
    ()                                           -- 全体平均
)
ORDER BY c.grade NULLS LAST, c.class_name NULLS LAST, sub.subject_name NULLS LAST;

-- 2. ROLLUP
-- 階層的な集計（小計と合計を含む）
SELECT 
    c.grade,
    c.class_name,
    COUNT(s.student_id) AS student_count,
    AVG(sc.score) AS avg_score
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1
    AND sc.subject_id = 2  -- 数学
WHERE sc.score IS NOT NULL
GROUP BY ROLLUP(c.grade, c.class_name)
ORDER BY c.grade NULLS LAST, c.class_name NULLS LAST;

-- 3. CUBE
-- すべての組み合わせで集計
SELECT 
    c.grade,
    s.gender,
    sub.subject_name,
    COUNT(sc.score) AS score_count,
    AVG(sc.score) AS avg_score
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
  AND sub.subject_id IN (1, 2)  -- 国語と数学のみ
GROUP BY CUBE(c.grade, s.gender, sub.subject_name)
ORDER BY c.grade NULLS LAST, s.gender NULLS LAST, sub.subject_name NULLS LAST;

-- 4. GROUPING関数
-- NULL値が集計によるものか元データによるものかを判別
SELECT 
    c.grade,
    c.class_name,
    CASE 
        WHEN GROUPING(c.grade) = 1 THEN '全学年'
        ELSE c.grade::text || '年'
    END AS grade_label,
    CASE 
        WHEN GROUPING(c.class_name) = 1 THEN '学年計'
        ELSE c.class_name
    END AS class_label,
    COUNT(s.student_id) AS student_count,
    AVG(sc.score) AS avg_score
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1
    AND sc.subject_id = 3  -- 英語
WHERE sc.score IS NOT NULL
GROUP BY ROLLUP(c.grade, c.class_name)
ORDER BY c.grade NULLS LAST, c.class_name NULLS LAST;

-- 5. ウィンドウ関数との組み合わせ
-- GROUP BYの結果に対してランキングを付ける
WITH class_subject_avg AS (
    SELECT 
        c.class_name,
        sub.subject_name,
        AVG(sc.score) AS avg_score,
        COUNT(sc.score) AS student_count
    FROM workshop.scores sc
    INNER JOIN workshop.students s ON sc.student_id = s.student_id
    INNER JOIN workshop.classes c ON s.class_id = c.class_id
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
    GROUP BY c.class_name, sub.subject_name
)
SELECT 
    class_name,
    subject_name,
    avg_score,
    student_count,
    RANK() OVER (PARTITION BY subject_name ORDER BY avg_score DESC) AS subject_rank,
    RANK() OVER (ORDER BY avg_score DESC) AS overall_rank
FROM class_subject_avg
ORDER BY overall_rank, subject_name;

-- 6. 累積集計
-- 時系列での累積平均点
SELECT 
    e.exam_name,
    e.exam_date,
    sub.subject_name,
    AVG(sc.score) AS exam_avg_score,
    AVG(AVG(sc.score)) OVER (
        PARTITION BY sub.subject_name 
        ORDER BY e.exam_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_avg_score
FROM workshop.scores sc
INNER JOIN workshop.exams e ON sc.exam_id = e.exam_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.score IS NOT NULL
GROUP BY e.exam_id, e.exam_name, e.exam_date, sub.subject_id, sub.subject_name
ORDER BY sub.subject_name, e.exam_date;

-- 7. パーセンタイル集計
-- 成績の分布を分析
SELECT 
    sub.subject_name,
    COUNT(sc.score) AS score_count,
    MIN(sc.score) AS min_score,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sc.score) AS q1,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sc.score) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sc.score) AS q3,
    MAX(sc.score) AS max_score,
    AVG(sc.score) AS avg_score,
    STDDEV(sc.score) AS std_dev
FROM workshop.scores sc
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
GROUP BY sub.subject_id, sub.subject_name
ORDER BY sub.subject_name;

-- 8. 条件付き集計の応用
-- 各生徒の科目別成績評価分布
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    COUNT(CASE WHEN sc.score >= 90 THEN 1 END) AS a_count,
    COUNT(CASE WHEN sc.score >= 80 AND sc.score < 90 THEN 1 END) AS b_count,
    COUNT(CASE WHEN sc.score >= 70 AND sc.score < 80 THEN 1 END) AS c_count,
    COUNT(CASE WHEN sc.score >= 60 AND sc.score < 70 THEN 1 END) AS d_count,
    COUNT(CASE WHEN sc.score < 60 THEN 1 END) AS f_count,
    COUNT(sc.score) AS total_tests,
    AVG(sc.score) AS avg_score
FROM workshop.students s
INNER JOIN workshop.scores sc ON s.student_id = sc.student_id
WHERE sc.score IS NOT NULL
GROUP BY s.student_id, s.last_name, s.first_name
HAVING COUNT(sc.score) >= 5  -- 5科目以上受験した生徒のみ
ORDER BY avg_score DESC;

-- 9. WITH RECURSIVEを使った階層的集計
-- 成績ランクごとの人数を累積で表示
WITH score_ranges AS (
    SELECT 
        1 AS range_order,
        '90点以上' AS range_name,
        90 AS min_score,
        100 AS max_score
    UNION ALL SELECT 2, '80-89点', 80, 89
    UNION ALL SELECT 3, '70-79点', 70, 79
    UNION ALL SELECT 4, '60-69点', 60, 69
    UNION ALL SELECT 5, '60点未満', 0, 59
),
range_counts AS (
    SELECT 
        sr.range_order,
        sr.range_name,
        COUNT(sc.score_id) AS count_in_range
    FROM score_ranges sr
    LEFT JOIN workshop.scores sc 
        ON sc.score >= sr.min_score 
        AND sc.score <= sr.max_score
        AND sc.exam_id = 1
        AND sc.subject_id = 2  -- 数学
        AND sc.score IS NOT NULL
    GROUP BY sr.range_order, sr.range_name
)
SELECT 
    range_order,
    range_name,
    count_in_range,
    SUM(count_in_range) OVER (ORDER BY range_order DESC) AS cumulative_count,
    ROUND(count_in_range * 100.0 / SUM(count_in_range) OVER (), 1) AS percentage,
    ROUND(SUM(count_in_range) OVER (ORDER BY range_order DESC) * 100.0 / SUM(count_in_range) OVER (), 1) AS cumulative_percentage
FROM range_counts
ORDER BY range_order;

-- 10. 動的クロス集計
-- 科目を列として展開した成績表
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    MAX(CASE WHEN sub.subject_name = '国語' THEN sc.score END) AS japanese,
    MAX(CASE WHEN sub.subject_name = '数学' THEN sc.score END) AS math,
    MAX(CASE WHEN sub.subject_name = '英語' THEN sc.score END) AS english,
    MAX(CASE WHEN sub.subject_name = '理科' THEN sc.score END) AS science,
    MAX(CASE WHEN sub.subject_name = '社会' THEN sc.score END) AS social,
    COUNT(sc.score) AS subjects_taken,
    SUM(sc.score) AS total_score,
    AVG(sc.score) AS avg_score,
    RANK() OVER (PARTITION BY c.class_id ORDER BY AVG(sc.score) DESC) AS class_rank
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc ON s.student_id = sc.student_id AND sc.exam_id = 1
LEFT JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.score IS NOT NULL
GROUP BY s.student_id, s.last_name, s.first_name, c.class_id, c.class_name
ORDER BY c.class_name, class_rank;