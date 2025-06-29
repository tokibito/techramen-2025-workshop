-- SQL基礎トレーニング: INSERT, UPDATE, DELETE
-- ===========================================
-- 目的: データの挿入、更新、削除の基本操作を学習
-- 対象テーブル: students（生徒）, scores（成績）

-- 注意：実習環境では実際にデータを変更します
-- 必要に応じてトランザクションを使用してください

-- トランザクションの開始
BEGIN;

-- 1. INSERT - 基本的なデータ挿入
-- 新しい生徒の追加（転入生）
INSERT INTO workshop.students (
    student_number, 
    last_name, 
    first_name, 
    gender, 
    birth_date, 
    class_id, 
    enrollment_date
) VALUES (
    '2024111', 
    '高橋', 
    '太郎', 
    'M', 
    '2011-09-01', 
    1, 
    '2024-09-01'
);

-- 2. INSERT - 複数行の一括挿入
-- 追試の成績を追加
INSERT INTO workshop.scores (
    student_id, 
    subject_id, 
    exam_id, 
    score, 
    is_absent
) VALUES 
    (61, 1, 1, 75, FALSE),  -- 国語
    (61, 2, 1, 82, FALSE),  -- 数学
    (61, 3, 1, 78, FALSE),  -- 英語
    (61, 4, 1, 85, FALSE),  -- 理科
    (61, 5, 1, 80, FALSE);  -- 社会

-- 挿入結果の確認
SELECT s.*, c.class_name 
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
WHERE s.student_number = '2024111';

-- 3. INSERT ... SELECT - 他のテーブルからのデータ挿入
-- 補習テストの成績を一括登録（欠席者全員に50点を付与）
INSERT INTO workshop.scores (student_id, subject_id, exam_id, score, is_absent)
SELECT 
    sc.student_id,
    sc.subject_id,
    sc.exam_id,
    50,  -- 補習テストの基準点
    FALSE
FROM workshop.scores sc
WHERE sc.is_absent = TRUE
  AND sc.exam_id = 1  -- 1学期中間テスト
  AND sc.score IS NULL
ON CONFLICT (student_id, subject_id, exam_id) DO NOTHING;

-- 4. UPDATE - 基本的なデータ更新
-- 特定の生徒の成績を更新（採点ミスの修正）
UPDATE workshop.scores
SET score = 85
WHERE student_id = 1 
  AND subject_id = 2  -- 数学
  AND exam_id = 1;    -- 1学期中間テスト

-- 5. UPDATE - 複数列の更新
-- 欠席者の成績とフラグを更新
UPDATE workshop.scores
SET 
    score = NULL,
    is_absent = TRUE
WHERE student_id = 5 
  AND exam_id = 5;  -- 3学期期末テスト

-- 6. UPDATE - 条件付き更新
-- 成績に応じたボーナス点の付与
UPDATE workshop.scores
SET score = 
    CASE 
        WHEN score >= 95 THEN LEAST(100, score + 5)  -- 95点以上は5点加点
        WHEN score >= 90 THEN LEAST(100, score + 3)  -- 90点以上は3点加点
        WHEN score >= 85 THEN LEAST(100, score + 2)  -- 85点以上は2点加点
        ELSE score  -- その他は変更なし
    END
WHERE exam_id = 1  -- 1学期中間テスト
  AND subject_id = 3  -- 英語
  AND score IS NOT NULL;

-- 更新結果の確認
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score,
    sc.is_absent
FROM workshop.scores sc
JOIN workshop.students s ON sc.student_id = s.student_id
JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
  AND s.student_id IN (1, 5)
ORDER BY s.student_id, sub.subject_id;

-- 7. UPDATE - JOINを使用した更新
-- 3年生全員の卒業試験ボーナス加点
UPDATE workshop.scores sc
SET score = LEAST(100, score + 5)
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id
WHERE sc.student_id = s.student_id
  AND c.grade = 3
  AND sc.exam_id = 5  -- 3学期期末テスト
  AND sc.score IS NOT NULL;

-- 8. DELETE - 基本的なデータ削除
-- 誤って登録した成績データの削除
DELETE FROM workshop.scores
WHERE student_id = 61  -- 追加した転入生
  AND exam_id = 1;

-- 9. DELETE - 条件付き削除
-- 転入生のデータを削除（外部キー制約に注意）
-- まず成績データを削除
DELETE FROM workshop.scores
WHERE student_id = (
    SELECT student_id 
    FROM workshop.students 
    WHERE student_number = '2024111'
);

-- 次に生徒データを削除
DELETE FROM workshop.students
WHERE student_number = '2024111';

-- 10. TRUNCATE - テーブルの全データ削除
-- 注意：この操作は全データを削除します！
-- TRUNCATE TABLE workshop.scores;

-- 変更内容の確認
SELECT 
    '生徒数' AS item,
    COUNT(*) AS count 
FROM workshop.students
UNION ALL
SELECT 
    '成績データ数' AS item,
    COUNT(*) AS count 
FROM workshop.scores;

-- トランザクションの確定（コミット）
-- 実際に変更を適用する場合はCOMMIT
-- 変更を取り消す場合はROLLBACK
ROLLBACK;  -- 今回は実習のため変更を取り消す

-- 元のデータが保持されていることを確認
SELECT COUNT(*) as student_count FROM workshop.students;