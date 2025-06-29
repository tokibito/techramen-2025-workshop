-- SQL GROUP BY編: 実践的な集計例
-- ==============================
-- 目的: 実務でよく使われる集計パターンを学習

-- 1. 月次レポート形式の集計
-- テストごとの各クラスの成績サマリー
SELECT 
    e.exam_name,
    e.exam_date,
    c.class_name,
    COUNT(DISTINCT s.student_id) AS student_count,
    COUNT(sc.score_id) AS test_count,
    COUNT(DISTINCT sc.subject_id) AS subjects_tested,
    AVG(sc.score) AS avg_score,
    MIN(sc.score) AS min_score,
    MAX(sc.score) AS max_score,
    STDDEV(sc.score) AS std_dev,
    COUNT(CASE WHEN sc.score >= 80 THEN 1 END) AS high_score_count,
    COUNT(CASE WHEN sc.score < 60 THEN 1 END) AS low_score_count,
    COUNT(CASE WHEN sc.is_absent = TRUE THEN 1 END) AS absent_count
FROM workshop.exams e
CROSS JOIN workshop.classes c
INNER JOIN workshop.students s ON c.class_id = s.class_id
LEFT JOIN workshop.scores sc 
    ON e.exam_id = sc.exam_id 
    AND s.student_id = sc.student_id
GROUP BY e.exam_id, e.exam_name, e.exam_date, c.class_id, c.class_name
ORDER BY e.exam_date, c.class_name;

-- 2. 前回比較レポート
-- 各生徒の前回テストとの比較
WITH score_with_prev AS (
    SELECT 
        s.student_id,
        s.last_name || ' ' || s.first_name AS student_name,
        sub.subject_name,
        e.exam_number,
        e.exam_name,
        sc.score,
        LAG(sc.score) OVER (
            PARTITION BY s.student_id, sub.subject_id 
            ORDER BY e.exam_number
        ) AS prev_score
    FROM workshop.students s
    INNER JOIN workshop.scores sc ON s.student_id = sc.student_id
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    INNER JOIN workshop.exams e ON sc.exam_id = e.exam_id
    WHERE sc.score IS NOT NULL
)
SELECT 
    exam_name,
    subject_name,
    COUNT(*) AS student_count,
    AVG(score) AS avg_score,
    AVG(prev_score) AS prev_avg_score,
    AVG(score - prev_score) AS avg_improvement,
    COUNT(CASE WHEN score > prev_score THEN 1 END) AS improved_count,
    COUNT(CASE WHEN score = prev_score THEN 1 END) AS same_count,
    COUNT(CASE WHEN score < prev_score THEN 1 END) AS declined_count
FROM score_with_prev
WHERE prev_score IS NOT NULL
GROUP BY exam_number, exam_name, subject_name
ORDER BY exam_number, subject_name;

-- 3. トップ/ボトム分析
-- 各科目の上位5名と下位5名
WITH ranked_scores AS (
    SELECT 
        s.student_id,
        s.last_name || ' ' || s.first_name AS student_name,
        c.class_name,
        sub.subject_name,
        sc.score,
        ROW_NUMBER() OVER (PARTITION BY sub.subject_id ORDER BY sc.score DESC) AS rank_desc,
        ROW_NUMBER() OVER (PARTITION BY sub.subject_id ORDER BY sc.score ASC) AS rank_asc
    FROM workshop.scores sc
    INNER JOIN workshop.students s ON sc.student_id = s.student_id
    INNER JOIN workshop.classes c ON s.class_id = c.class_id
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
)
SELECT 
    subject_name,
    'Top 5' AS category,
    student_name,
    class_name,
    score,
    rank_desc AS rank
FROM ranked_scores
WHERE rank_desc <= 5

UNION ALL

SELECT 
    subject_name,
    'Bottom 5' AS category,
    student_name,
    class_name,
    score,
    rank_asc AS rank
FROM ranked_scores
WHERE rank_asc <= 5

ORDER BY subject_name, category DESC, rank;

-- 4. 異常値検出
-- 平均から大きく外れた成績を検出
WITH stats AS (
    SELECT 
        sub.subject_id,
        sub.subject_name,
        AVG(sc.score) AS avg_score,
        STDDEV(sc.score) AS std_dev
    FROM workshop.scores sc
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
    GROUP BY sub.subject_id, sub.subject_name
)
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score,
    st.avg_score,
    st.std_dev,
    ROUND((sc.score - st.avg_score) / st.std_dev, 2) AS z_score,
    CASE 
        WHEN ABS(sc.score - st.avg_score) > 2 * st.std_dev THEN '異常値'
        WHEN ABS(sc.score - st.avg_score) > 1.5 * st.std_dev THEN '要注意'
        ELSE '正常'
    END AS status
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
INNER JOIN stats st ON sub.subject_id = st.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
  AND ABS(sc.score - st.avg_score) > 1.5 * st.std_dev
ORDER BY ABS((sc.score - st.avg_score) / st.std_dev) DESC;

-- 5. 相関分析
-- 科目間の成績相関
WITH subject_scores AS (
    SELECT 
        s.student_id,
        MAX(CASE WHEN sub.subject_name = '数学' THEN sc.score END) AS math_score,
        MAX(CASE WHEN sub.subject_name = '理科' THEN sc.score END) AS science_score,
        MAX(CASE WHEN sub.subject_name = '英語' THEN sc.score END) AS english_score,
        MAX(CASE WHEN sub.subject_name = '国語' THEN sc.score END) AS japanese_score
    FROM workshop.students s
    INNER JOIN workshop.scores sc ON s.student_id = sc.student_id
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
    GROUP BY s.student_id
)
SELECT 
    '数学-理科' AS subject_pair,
    COUNT(*) AS sample_count,
    ROUND(AVG(math_score), 1) AS avg_subject1,
    ROUND(AVG(science_score), 1) AS avg_subject2,
    ROUND(CORR(math_score, science_score), 3) AS correlation
FROM subject_scores
WHERE math_score IS NOT NULL AND science_score IS NOT NULL

UNION ALL

SELECT 
    '英語-国語' AS subject_pair,
    COUNT(*) AS sample_count,
    ROUND(AVG(english_score), 1) AS avg_subject1,
    ROUND(AVG(japanese_score), 1) AS avg_subject2,
    ROUND(CORR(english_score, japanese_score), 3) AS correlation
FROM subject_scores
WHERE english_score IS NOT NULL AND japanese_score IS NOT NULL

ORDER BY correlation DESC;

-- 6. 出席率と成績の関係
-- 欠席回数と平均点の関係を分析
WITH attendance_stats AS (
    SELECT 
        s.student_id,
        s.last_name || ' ' || s.first_name AS student_name,
        COUNT(CASE WHEN sc.is_absent = TRUE THEN 1 END) AS absent_count,
        COUNT(sc.score_id) AS total_tests,
        COUNT(CASE WHEN sc.score IS NOT NULL THEN 1 END) AS attended_tests,
        AVG(CASE WHEN sc.score IS NOT NULL THEN sc.score END) AS avg_score
    FROM workshop.students s
    LEFT JOIN workshop.scores sc ON s.student_id = sc.student_id
    GROUP BY s.student_id, s.last_name, s.first_name
)
SELECT 
    CASE 
        WHEN absent_count = 0 THEN '皆勤'
        WHEN absent_count <= 2 THEN '1-2回欠席'
        WHEN absent_count <= 5 THEN '3-5回欠席'
        ELSE '6回以上欠席'
    END AS absence_category,
    COUNT(*) AS student_count,
    AVG(avg_score) AS avg_score,
    MIN(avg_score) AS min_avg_score,
    MAX(avg_score) AS max_avg_score
FROM attendance_stats
GROUP BY 
    CASE 
        WHEN absent_count = 0 THEN '皆勤'
        WHEN absent_count <= 2 THEN '1-2回欠席'
        WHEN absent_count <= 5 THEN '3-5回欠席'
        ELSE '6回以上欠席'
    END
ORDER BY avg_score DESC;

-- 7. 成績推移のトレンド分析
-- 各クラスの平均点推移
SELECT 
    c.class_name,
    e.exam_name,
    e.exam_date,
    AVG(sc.score) AS avg_score,
    COUNT(sc.score) AS test_count,
    AVG(AVG(sc.score)) OVER (
        PARTITION BY c.class_id 
        ORDER BY e.exam_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3,
    FIRST_VALUE(AVG(sc.score)) OVER (
        PARTITION BY c.class_id 
        ORDER BY e.exam_date
    ) AS first_exam_avg,
    AVG(sc.score) - FIRST_VALUE(AVG(sc.score)) OVER (
        PARTITION BY c.class_id 
        ORDER BY e.exam_date
    ) AS improvement_from_first
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.exams e ON sc.exam_id = e.exam_id
WHERE sc.score IS NOT NULL
GROUP BY c.class_id, c.class_name, e.exam_id, e.exam_name, e.exam_date
ORDER BY c.class_name, e.exam_date;

-- 8. 成績分布のヒストグラム
-- 10点刻みでの成績分布
WITH score_bins AS (
    SELECT 
        sub.subject_name,
        FLOOR(sc.score / 10) * 10 AS score_range_start,
        COUNT(*) AS count
    FROM workshop.scores sc
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
    GROUP BY sub.subject_name, FLOOR(sc.score / 10)
)
SELECT 
    subject_name,
    score_range_start || '-' || (score_range_start + 9) AS score_range,
    count,
    REPEAT('■', count::int) AS histogram,
    ROUND(count * 100.0 / SUM(count) OVER (PARTITION BY subject_name), 1) AS percentage
FROM score_bins
ORDER BY subject_name, score_range_start;