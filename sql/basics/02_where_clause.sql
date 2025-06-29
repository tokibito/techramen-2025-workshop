-- SQL基礎トレーニング: WHERE句による絞り込み
-- ==========================================
-- 目的: WHERE句を使用したデータの絞り込み方法を学習
-- 対象テーブル: students（生徒）, classes（学級）, scores（成績）

-- 1. 基本的な比較演算子
-- 等号（=）による完全一致
SELECT * 
FROM workshop.students
WHERE class_id = 1;

-- 不等号による比較
-- 80点以上の成績を取得
SELECT 
    score_id,
    student_id,
    subject_id,
    score
FROM workshop.scores
WHERE score >= 80;

-- 2. 複数条件の組み合わせ（AND）
-- 1年生の男子生徒
SELECT s.*, c.grade
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
WHERE c.grade = 1 
  AND s.gender = 'M';

-- 3. 複数条件の組み合わせ（OR）
-- 1年1組または1年2組の生徒
SELECT * 
FROM workshop.students
WHERE class_id = 1 
   OR class_id = 2;

-- 4. IN演算子
-- 数学、英語、理科の成績
SELECT * 
FROM workshop.scores
WHERE subject_id IN (2, 3, 4);

-- 5. NOT IN演算子
-- 国語以外の成績
SELECT * 
FROM workshop.scores
WHERE subject_id NOT IN (1);

-- 6. BETWEEN演算子
-- 範囲指定（境界値を含む）
-- 60点以上80点以下の成績
SELECT 
    score_id,
    student_id,
    subject_id,
    score
FROM workshop.scores
WHERE score BETWEEN 60 AND 80;

-- 7. LIKE演算子によるパターンマッチング
-- %: 0文字以上の任意の文字
-- _: 1文字の任意の文字

-- 「田」で終わる姓の生徒を検索
SELECT * 
FROM workshop.students
WHERE last_name LIKE '%田';

-- 学籍番号が「2024」で始まる1年生
SELECT * 
FROM workshop.students
WHERE student_number LIKE '2024%';

-- 8. NULL値の検索
-- IS NULL / IS NOT NULL を使用
-- 欠席で成績がNULLのデータ
SELECT * 
FROM workshop.scores
WHERE score IS NULL;

-- 成績が記録されているデータ
SELECT * 
FROM workshop.scores
WHERE score IS NOT NULL;

-- 9. 複雑な条件の組み合わせ
-- 括弧を使用して条件の優先順位を明確にする
-- 1年生または2年生で、かつ女子生徒
SELECT 
    s.student_id,
    s.last_name,
    s.first_name,
    s.gender,
    c.grade
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
WHERE (c.grade = 1 OR c.grade = 2)
  AND s.gender = 'F';

-- 10. 日付の比較
-- 2010年以降に生まれた生徒
SELECT 
    student_id,
    last_name,
    first_name,
    birth_date
FROM workshop.students
WHERE birth_date >= '2010-01-01'
ORDER BY birth_date;

-- 11. EXISTS演算子
-- 90点以上を取ったことがある生徒
SELECT 
    s.student_id,
    s.last_name,
    s.first_name
FROM workshop.students s
WHERE EXISTS (
    SELECT 1 
    FROM workshop.scores sc
    WHERE sc.student_id = s.student_id
      AND sc.score >= 90
);

-- 12. テスト情報との組み合わせ
-- 1学期中間テストの成績のみ
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score
FROM workshop.scores sc
JOIN workshop.students s ON sc.student_id = s.student_id
JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
JOIN workshop.exams e ON sc.exam_id = e.exam_id
WHERE e.exam_number = 1;