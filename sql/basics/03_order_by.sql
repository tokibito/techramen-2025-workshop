-- SQL基礎トレーニング: ORDER BY句による並び替え
-- ============================================
-- 目的: ORDER BY句を使用したデータの並び替え方法を学習
-- 対象テーブル: students（生徒）, scores（成績）, exams（テスト）

-- 1. 基本的な昇順ソート（ASC）
-- ASCは省略可能（デフォルトは昇順）
-- 成績を低い順に表示
SELECT 
    score_id,
    student_id,
    subject_id,
    score
FROM workshop.scores
WHERE score IS NOT NULL
ORDER BY score ASC;

-- 2. 降順ソート（DESC）
-- 成績の高い順に表示
SELECT 
    score_id,
    student_id,
    subject_id,
    score
FROM workshop.scores
WHERE score IS NOT NULL
ORDER BY score DESC;

-- 3. 複数列でのソート
-- 学年順、その中で学籍番号順
SELECT 
    s.student_id,
    s.student_number,
    s.last_name,
    s.first_name,
    c.grade,
    c.class_number
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
ORDER BY c.grade ASC, s.student_number ASC;

-- 4. 列番号を使用したソート
-- SELECT句の列番号で指定（1から始まる）
SELECT 
    c.grade,
    c.class_number,
    s.last_name,
    s.first_name
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
ORDER BY 1, 2, 3;  -- 学年、クラス、姓の順

-- 5. エイリアスを使用したソート
-- 平均点の高い順
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS full_name,
    AVG(sc.score) AS average_score
FROM workshop.students s
JOIN workshop.scores sc ON s.student_id = sc.student_id
WHERE sc.score IS NOT NULL
GROUP BY s.student_id, s.last_name, s.first_name
ORDER BY average_score DESC;

-- 6. NULL値の扱い
-- NULLS FIRST / NULLS LAST
-- 欠席者を最後に表示
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score
FROM workshop.scores sc
JOIN workshop.students s ON sc.student_id = s.student_id
JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
JOIN workshop.exams e ON sc.exam_id = e.exam_id
WHERE e.exam_number = 1
ORDER BY sc.score NULLS LAST;

-- 7. 文字列のソート
-- 生徒の姓名でソート
SELECT 
    student_id,
    last_name,
    first_name,
    student_number
FROM workshop.students
ORDER BY last_name, first_name;

-- 8. 日付のソート
-- テスト日の新しい順（降順）に表示
SELECT 
    exam_id,
    exam_name,
    exam_date,
    semester
FROM workshop.exams
ORDER BY exam_date DESC;

-- 9. CASE式を使用したカスタムソート
-- 成績ランクでソート
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    sc.score,
    CASE 
        WHEN sc.score >= 90 THEN 'A'
        WHEN sc.score >= 80 THEN 'B'
        WHEN sc.score >= 70 THEN 'C'
        WHEN sc.score >= 60 THEN 'D'
        ELSE 'F'
    END AS grade_rank
FROM workshop.scores sc
JOIN workshop.students s ON sc.student_id = s.student_id
WHERE sc.subject_id = 1  -- 国語
  AND sc.exam_id = 1     -- 1学期中間テスト
  AND sc.score IS NOT NULL
ORDER BY 
    CASE 
        WHEN sc.score >= 90 THEN 1
        WHEN sc.score >= 80 THEN 2
        WHEN sc.score >= 70 THEN 3
        WHEN sc.score >= 60 THEN 4
        ELSE 5
    END,
    sc.score DESC;

-- 10. TOP-N クエリ
-- 各教科の成績トップ5を取得
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score
FROM workshop.scores sc
JOIN workshop.students s ON sc.student_id = s.student_id
JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
  AND sc.score IS NOT NULL
  AND sub.subject_id = 2  -- 数学
ORDER BY sc.score DESC
LIMIT 5;

-- 11. OFFSET と LIMIT の組み合わせ
-- 6位から10位の結果を取得（ページング）
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sc.score,
    RANK() OVER (ORDER BY sc.score DESC) AS rank
FROM workshop.scores sc
JOIN workshop.students s ON sc.student_id = s.student_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
  AND sc.subject_id = 2  -- 数学
  AND sc.score IS NOT NULL
ORDER BY sc.score DESC
LIMIT 5 OFFSET 5;

-- 12. 複数条件での並び替え
-- 学年別、成績順
SELECT 
    c.grade,
    c.class_name,
    s.last_name || ' ' || s.first_name AS student_name,
    AVG(sc.score) AS average_score
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
JOIN workshop.scores sc ON s.student_id = sc.student_id
WHERE sc.score IS NOT NULL
GROUP BY c.grade, c.class_name, s.student_id, s.last_name, s.first_name
ORDER BY c.grade, average_score DESC;