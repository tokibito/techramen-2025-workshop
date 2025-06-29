-- SQL GROUP BY編: GROUP BYの基本
-- ===============================
-- 目的: GROUP BYと集計関数の基本的な使い方を学習
-- 対象テーブル: students（生徒）, scores（成績）, classes（学級）

-- 1. 基本的なGROUP BY
-- クラスごとの生徒数を集計
SELECT 
    c.class_name,
    COUNT(s.student_id) AS student_count
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
GROUP BY c.class_name
ORDER BY c.class_name;

-- 2. 集計関数の種類
-- COUNT, SUM, AVG, MAX, MIN の使い方
SELECT 
    sub.subject_name,
    COUNT(sc.score_id) AS test_count,
    SUM(sc.score) AS total_score,
    AVG(sc.score) AS avg_score,
    MAX(sc.score) AS max_score,
    MIN(sc.score) AS min_score
FROM workshop.scores sc
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
  AND sc.score IS NOT NULL
GROUP BY sub.subject_name
ORDER BY avg_score DESC;

-- 3. 複数列でのGROUP BY
-- 学年・クラスごとの生徒数
SELECT 
    c.grade,
    c.class_number,
    c.class_name,
    COUNT(s.student_id) AS student_count
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
GROUP BY c.grade, c.class_number, c.class_name
ORDER BY c.grade, c.class_number;

-- 4. GROUP BYとWHERE句の組み合わせ
-- 条件を絞り込んでから集計
SELECT 
    c.class_name,
    sub.subject_name,
    AVG(sc.score) AS avg_score
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE c.grade = 1  -- 1年生のみ
  AND sc.exam_id = 1  -- 1学期中間テスト
  AND sc.score IS NOT NULL
GROUP BY c.class_name, sub.subject_name
ORDER BY c.class_name, sub.subject_name;

-- 5. HAVING句による集計結果の絞り込み
-- 平均点が70点以上のクラス・科目のみ表示
SELECT 
    c.class_name,
    sub.subject_name,
    AVG(sc.score) AS avg_score,
    COUNT(sc.score_id) AS student_count
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
  AND sc.score IS NOT NULL
GROUP BY c.class_name, sub.subject_name
HAVING AVG(sc.score) >= 70
ORDER BY avg_score DESC;

-- 6. COUNT(*)とCOUNT(列名)の違い
-- NULL値の扱いに注意
SELECT 
    c.class_name,
    COUNT(*) AS total_records,
    COUNT(sc.score) AS scores_with_value,
    COUNT(*) - COUNT(sc.score) AS null_or_absent_count
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.subject_id = 1  -- 国語
GROUP BY c.class_name
ORDER BY c.class_name;

-- 7. DISTINCT付きCOUNT
-- 重複を除外した集計
SELECT 
    e.exam_name,
    COUNT(DISTINCT sc.student_id) AS students_who_took_exam,
    COUNT(DISTINCT sc.subject_id) AS subjects_tested,
    COUNT(sc.score_id) AS total_scores_recorded
FROM workshop.exams e
LEFT JOIN workshop.scores sc ON e.exam_id = sc.exam_id
GROUP BY e.exam_id, e.exam_name
ORDER BY e.exam_id;

-- 8. CASE式との組み合わせ
-- 条件別の集計
SELECT 
    c.class_name,
    COUNT(CASE WHEN sc.score >= 80 THEN 1 END) AS excellent_count,
    COUNT(CASE WHEN sc.score >= 60 AND sc.score < 80 THEN 1 END) AS good_count,
    COUNT(CASE WHEN sc.score < 60 THEN 1 END) AS needs_improvement_count,
    COUNT(CASE WHEN sc.is_absent = TRUE THEN 1 END) AS absent_count
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.subject_id = 2  -- 数学
GROUP BY c.class_name
ORDER BY c.class_name;

-- 9. 文字列の集約
-- STRING_AGG関数を使用（PostgreSQL特有）
SELECT 
    c.class_name,
    COUNT(s.student_id) AS student_count,
    STRING_AGG(s.last_name || ' ' || s.first_name, ', ' ORDER BY s.last_name, s.first_name) AS student_names
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
WHERE c.grade = 1  -- 1年生のみ
GROUP BY c.class_name
ORDER BY c.class_name;

-- 10. 集計結果の割合計算
-- 各クラスの各科目の平均点と学年平均との比較
WITH grade_avg AS (
    SELECT 
        c.grade,
        sub.subject_id,
        sub.subject_name,
        AVG(sc.score) AS grade_avg_score
    FROM workshop.scores sc
    INNER JOIN workshop.students s ON sc.student_id = s.student_id
    INNER JOIN workshop.classes c ON s.class_id = c.class_id
    INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
    GROUP BY c.grade, sub.subject_id, sub.subject_name
)
SELECT 
    c.class_name,
    sub.subject_name,
    AVG(sc.score) AS class_avg_score,
    ga.grade_avg_score,
    ROUND(AVG(sc.score) - ga.grade_avg_score, 1) AS diff_from_grade_avg,
    ROUND(AVG(sc.score) * 100.0 / ga.grade_avg_score, 1) AS percentage_of_grade_avg
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
INNER JOIN grade_avg ga 
    ON c.grade = ga.grade 
    AND sub.subject_id = ga.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
GROUP BY c.class_name, sub.subject_name, ga.grade_avg_score
ORDER BY c.class_name, sub.subject_name;