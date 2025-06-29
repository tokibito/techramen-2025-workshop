-- SQL JOIN編: OUTER JOIN（外部結合）
-- ==================================
-- 目的: LEFT JOIN, RIGHT JOIN, FULL OUTER JOINの使い方を学習
-- 外部結合: 片方または両方のテーブルにしかないデータも含めて結合

-- 1. LEFT JOIN（左外部結合）の基本
-- すべての生徒を表示（成績未登録の生徒も含む）
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    s.class_id,
    sc.score_id,
    sc.score
FROM workshop.students s
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.subject_id = 1  -- 国語
ORDER BY s.student_id;

-- 2. LEFT JOINでNULL値を確認
-- 特定のテストで成績が登録されていない生徒を特定
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    CASE 
        WHEN sc.score_id IS NULL THEN '成績未登録'
        WHEN sc.is_absent = TRUE THEN '欠席'
        ELSE '出席'
    END AS status
FROM workshop.students s
LEFT JOIN workshop.classes c 
    ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.subject_id = 1  -- 国語
WHERE sc.score_id IS NULL;

-- 3. LEFT JOINと集計
-- クラスごとの生徒数と成績登録者数
SELECT 
    c.class_name,
    COUNT(DISTINCT s.student_id) AS total_students,
    COUNT(DISTINCT sc.student_id) AS students_with_scores,
    COUNT(DISTINCT s.student_id) - COUNT(DISTINCT sc.student_id) AS students_without_scores
FROM workshop.classes c
LEFT JOIN workshop.students s 
    ON c.class_id = s.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
GROUP BY c.class_name
ORDER BY c.class_name;

-- 4. 複数のLEFT JOIN
-- すべての生徒と成績情報（存在する場合）
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    COALESCE(sub.subject_name, '未受験') AS subject,
    COALESCE(sc.score, 0) AS score,
    COALESCE(
        CASE 
            WHEN sc.is_absent = TRUE THEN '欠席'
            WHEN sc.score IS NOT NULL THEN '出席'
            ELSE '未登録'
        END, 
        '未登録'
    ) AS attendance
FROM workshop.students s
LEFT JOIN workshop.classes c 
    ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
LEFT JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE s.class_id = 1  -- 1年1組のみ
ORDER BY s.student_id, sub.subject_id;

-- 5. RIGHT JOIN（右外部結合）
-- すべての教科と成績（成績がない教科も含む）
SELECT 
    sub.subject_id,
    sub.subject_name,
    COUNT(sc.score_id) AS score_count,
    AVG(sc.score) AS avg_score
FROM workshop.scores sc
RIGHT JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.score IS NOT NULL
GROUP BY sub.subject_id, sub.subject_name
ORDER BY sub.subject_id;

-- 6. RIGHT JOINをLEFT JOINに書き換え
-- 上記と同じ結果（一般的にはLEFT JOINの方が読みやすい）
SELECT 
    sub.subject_id,
    sub.subject_name,
    COUNT(sc.score_id) AS score_count,
    AVG(sc.score) AS avg_score
FROM workshop.subjects sub
LEFT JOIN workshop.scores sc 
    ON sub.subject_id = sc.subject_id
    AND sc.exam_id = 1  -- 1学期中間テスト
    AND sc.score IS NOT NULL
GROUP BY sub.subject_id, sub.subject_name
ORDER BY sub.subject_id;

-- 7. FULL OUTER JOIN（完全外部結合）
-- 生徒と成績のすべての組み合わせ
-- 成績がない生徒や、生徒がいない成績データも表示
SELECT 
    COALESCE(s.student_id, sc.student_id) AS student_id,
    COALESCE(s.last_name || ' ' || s.first_name, '生徒情報なし') AS student_name,
    COALESCE(sub.subject_name, '教科情報なし') AS subject,
    sc.score,
    CASE 
        WHEN s.student_id IS NULL THEN '生徒データ不明'
        WHEN sc.score_id IS NULL THEN '成績未登録'
        ELSE '正常'
    END AS data_status
FROM workshop.students s
FULL OUTER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
LEFT JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE s.student_id IS NULL OR sc.score_id IS NULL
ORDER BY student_id NULLS LAST;

-- 8. 外部結合を使った不整合データの検出
-- 存在しないクラスIDを持つ生徒を検出（テスト用）
BEGIN;

-- テストデータの挿入（存在しないクラスID）
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date)
VALUES ('TEST001', 'テスト', '太郎', 'M', '2010-01-01', 999, CURRENT_DATE);

SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    s.class_id,
    c.class_name
FROM workshop.students s
LEFT JOIN workshop.classes c 
    ON s.class_id = c.class_id
WHERE c.class_id IS NULL;

ROLLBACK;  -- テストデータをロールバック

-- 9. 外部結合と条件の位置
-- ON句での条件とWHERE句での条件の違い
-- ON句での条件：結合前に適用（80点以上の成績のみ結合）
SELECT 
    c.class_name,
    COUNT(DISTINCT s.student_id) AS total_students,
    COUNT(DISTINCT sc.student_id) AS high_score_students
FROM workshop.classes c
LEFT JOIN workshop.students s 
    ON c.class_id = s.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id 
    AND sc.score >= 80
    AND sc.exam_id = 1
    AND sc.subject_id = 2  -- 数学
GROUP BY c.class_name
ORDER BY c.class_name;

-- WHERE句での条件：結合後に適用（結果が異なる）
SELECT 
    c.class_name,
    COUNT(DISTINCT s.student_id) AS students_count
FROM workshop.classes c
LEFT JOIN workshop.students s 
    ON c.class_id = s.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1
    AND sc.subject_id = 2  -- 数学
WHERE sc.score >= 80 OR sc.score IS NULL
GROUP BY c.class_name
ORDER BY c.class_name;

-- 10. 実践的な例：全教科の成績一覧表
-- 生徒ごとの全教科の成績を横に並べて表示
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    MAX(CASE WHEN sub.subject_name = '国語' THEN sc.score END) AS 国語,
    MAX(CASE WHEN sub.subject_name = '数学' THEN sc.score END) AS 数学,
    MAX(CASE WHEN sub.subject_name = '英語' THEN sc.score END) AS 英語,
    MAX(CASE WHEN sub.subject_name = '理科' THEN sc.score END) AS 理科,
    MAX(CASE WHEN sub.subject_name = '社会' THEN sc.score END) AS 社会,
    COUNT(sc.score) AS subjects_taken,
    AVG(sc.score) AS average_score
FROM workshop.students s
LEFT JOIN workshop.classes c 
    ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.exam_id = 1  -- 1学期中間テスト
LEFT JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE c.grade = 1  -- 1年生のみ
GROUP BY s.student_id, s.last_name, s.first_name, c.class_name
ORDER BY c.class_name, s.student_id;