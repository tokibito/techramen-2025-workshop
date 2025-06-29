-- 応用問題の解答例
-- ==================

-- 問題11: 欠席と成績の関係
-- 欠席回数別に平均点を集計
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
        WHEN absent_count = 0 THEN '0回（皆勤）'
        WHEN absent_count <= 2 THEN '1-2回'
        WHEN absent_count <= 5 THEN '3-5回'
        WHEN absent_count <= 10 THEN '6-10回'
        ELSE '11回以上'
    END AS 欠席回数帯,
    COUNT(*) AS 生徒数,
    ROUND(AVG(avg_score), 1) AS 平均点,
    ROUND(MIN(avg_score), 1) AS 最低平均点,
    ROUND(MAX(avg_score), 1) AS 最高平均点,
    ROUND(STDDEV(avg_score), 1) AS 標準偏差
FROM attendance_stats
WHERE avg_score IS NOT NULL
GROUP BY 
    CASE 
        WHEN absent_count = 0 THEN '0回（皆勤）'
        WHEN absent_count <= 2 THEN '1-2回'
        WHEN absent_count <= 5 THEN '3-5回'
        WHEN absent_count <= 10 THEN '6-10回'
        ELSE '11回以上'
    END
ORDER BY 
    CASE 
        WHEN absent_count = 0 THEN 1
        WHEN absent_count <= 2 THEN 2
        WHEN absent_count <= 5 THEN 3
        WHEN absent_count <= 10 THEN 4
        ELSE 5
    END;

-- 問題12: クラス間の成績差
-- 各テストで最もクラス間の差が大きい科目
WITH class_subject_scores AS (
    SELECT 
        e.exam_id,
        e.exam_name,
        sub.subject_id,
        sub.subject_name,
        c.class_id,
        c.class_name,
        AVG(sc.score) AS avg_score
    FROM workshop.exams e
    CROSS JOIN workshop.subjects sub
    CROSS JOIN workshop.classes c
    LEFT JOIN workshop.students s ON c.class_id = s.class_id
    LEFT JOIN workshop.scores sc 
        ON s.student_id = sc.student_id 
        AND e.exam_id = sc.exam_id 
        AND sub.subject_id = sc.subject_id
    WHERE sc.score IS NOT NULL
    GROUP BY e.exam_id, e.exam_name, sub.subject_id, sub.subject_name, c.class_id, c.class_name
),
subject_ranges AS (
    SELECT 
        exam_id,
        exam_name,
        subject_id,
        subject_name,
        MAX(avg_score) AS max_avg,
        MIN(avg_score) AS min_avg,
        MAX(avg_score) - MIN(avg_score) AS score_range,
        COUNT(DISTINCT class_id) AS class_count
    FROM class_subject_scores
    GROUP BY exam_id, exam_name, subject_id, subject_name
    HAVING COUNT(DISTINCT class_id) > 1
)
SELECT 
    sr.exam_name AS テスト名,
    sr.subject_name AS 科目,
    ROUND(sr.max_avg, 1) AS 最高クラス平均,
    ROUND(sr.min_avg, 1) AS 最低クラス平均,
    ROUND(sr.score_range, 1) AS 差,
    (SELECT class_name FROM class_subject_scores css 
     WHERE css.exam_id = sr.exam_id 
       AND css.subject_id = sr.subject_id 
       AND css.avg_score = sr.max_avg 
     LIMIT 1) AS 最高クラス,
    (SELECT class_name FROM class_subject_scores css 
     WHERE css.exam_id = sr.exam_id 
       AND css.subject_id = sr.subject_id 
       AND css.avg_score = sr.min_avg 
     LIMIT 1) AS 最低クラス
FROM subject_ranges sr
WHERE sr.score_range = (
    SELECT MAX(score_range) 
    FROM subject_ranges sr2 
    WHERE sr2.exam_id = sr.exam_id
)
ORDER BY sr.exam_id, sr.score_range DESC;

-- 問題13: 成績向上者
-- 前回のテストと比較して最も成績が向上した生徒（各科目）
WITH score_changes AS (
    SELECT 
        s.student_id,
        s.last_name || ' ' || s.first_name AS student_name,
        c.class_name,
        sub.subject_id,
        sub.subject_name,
        e.exam_number,
        e.exam_name,
        sc.score AS current_score,
        LAG(sc.score) OVER (
            PARTITION BY s.student_id, sub.subject_id 
            ORDER BY e.exam_number
        ) AS prev_score,
        sc.score - LAG(sc.score) OVER (
            PARTITION BY s.student_id, sub.subject_id 
            ORDER BY e.exam_number
        ) AS score_change
    FROM workshop.students s
    INNER JOIN workshop.classes c ON s.class_id = c.class_id
    INNER JOIN workshop.scores sc ON s.student_id = sc.student_id
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    INNER JOIN workshop.exams e ON sc.exam_id = e.exam_id
    WHERE sc.score IS NOT NULL
),
ranked_improvements AS (
    SELECT 
        *,
        RANK() OVER (
            PARTITION BY subject_id, exam_number 
            ORDER BY score_change DESC
        ) AS improvement_rank
    FROM score_changes
    WHERE prev_score IS NOT NULL
      AND score_change > 0
)
SELECT 
    subject_name AS 科目,
    exam_name AS テスト,
    student_name AS 生徒名,
    class_name AS クラス,
    prev_score AS 前回点数,
    current_score AS 今回点数,
    score_change AS 向上点数,
    ROUND(score_change * 100.0 / prev_score, 1) AS "向上率(%)"
FROM ranked_improvements
WHERE improvement_rank = 1
ORDER BY subject_id, exam_number;

-- 補足: 全期間での総合的な成績向上者トップ10
WITH overall_improvements AS (
    SELECT 
        s.student_id,
        s.last_name || ' ' || s.first_name AS student_name,
        c.class_name,
        MIN(CASE WHEN e.exam_number = 1 THEN sc.score END) AS first_exam_score,
        MAX(CASE WHEN e.exam_number = 5 THEN sc.score END) AS last_exam_score,
        COUNT(DISTINCT CASE WHEN e.exam_number = 1 AND sc.score IS NOT NULL THEN sub.subject_id END) AS first_subjects,
        COUNT(DISTINCT CASE WHEN e.exam_number = 5 AND sc.score IS NOT NULL THEN sub.subject_id END) AS last_subjects
    FROM workshop.students s
    INNER JOIN workshop.classes c ON s.class_id = c.class_id
    LEFT JOIN workshop.scores sc ON s.student_id = sc.student_id
    LEFT JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    LEFT JOIN workshop.exams e ON sc.exam_id = e.exam_id
    GROUP BY s.student_id, s.last_name, s.first_name, c.class_name
),
score_averages AS (
    SELECT 
        student_id,
        student_name,
        class_name,
        AVG(first_exam_score) AS first_avg,
        AVG(last_exam_score) AS last_avg
    FROM overall_improvements
    WHERE first_subjects >= 3 AND last_subjects >= 3  -- 少なくとも3科目は受験
    GROUP BY student_id, student_name, class_name
)
SELECT 
    RANK() OVER (ORDER BY (last_avg - first_avg) DESC) AS 順位,
    student_name AS 生徒名,
    class_name AS クラス,
    ROUND(first_avg, 1) AS 初回平均点,
    ROUND(last_avg, 1) AS 最終平均点,
    ROUND(last_avg - first_avg, 1) AS 向上点数,
    ROUND((last_avg - first_avg) * 100.0 / first_avg, 1) AS "向上率(%)"
FROM score_averages
WHERE last_avg > first_avg
ORDER BY (last_avg - first_avg) DESC
LIMIT 10;