-- SQL基礎トレーニング: SELECT文の基本
-- =====================================
-- 目的: SELECT文の基本的な使い方を学習する
-- 対象テーブル: students（生徒）, classes（学級）, subjects（教科）

-- 1. すべての列を取得
-- アスタリスク（*）を使用してテーブルのすべての列を取得
SELECT * 
FROM workshop.students;

-- 2. 特定の列のみを取得
-- 必要な列だけを指定して取得（推奨）
SELECT 
    student_id,
    student_number,
    last_name,
    first_name,
    gender
FROM workshop.students;

-- 3. 列に別名（エイリアス）をつける
-- AS句を使用して、結果の列名を変更
SELECT 
    student_id AS 生徒ID,
    student_number AS 学籍番号,
    last_name AS 姓,
    first_name AS 名,
    gender AS 性別
FROM workshop.students;

-- 4. 文字列の結合
-- PostgreSQLでは || 演算子を使用
SELECT 
    student_id,
    last_name || ' ' || first_name AS full_name,
    student_number,
    class_id
FROM workshop.students;

-- 5. DISTINCT - 重複を除外
-- 学年の一覧を重複なしで取得
SELECT DISTINCT grade
FROM workshop.classes
ORDER BY grade;

-- 6. 計算列の作成
-- 生徒の年齢を計算
SELECT 
    student_id,
    last_name || ' ' || first_name AS full_name,
    birth_date,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) AS age
FROM workshop.students;

-- 7. CASE式による条件分岐
-- 学年による分類
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS full_name,
    c.grade,
    CASE 
        WHEN c.grade = 3 THEN '卒業学年'
        WHEN c.grade = 2 THEN '中学年'
        ELSE '新入生'
    END AS grade_category
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id;

-- 8. NULL値の扱い
-- COALESCE関数でNULL値をデフォルト値に置換
SELECT 
    student_id,
    subject_id,
    exam_id,
    COALESCE(score, 0) AS score_or_zero,
    CASE 
        WHEN is_absent = TRUE THEN '欠席'
        WHEN score IS NULL THEN '未記録'
        ELSE '出席'
    END AS attendance_status
FROM workshop.scores;

-- 9. 現在の日付・時刻の取得
-- PostgreSQLの日付関数
SELECT 
    CURRENT_DATE AS today,
    CURRENT_TIME AS current_time,
    CURRENT_TIMESTAMP AS now,
    NOW() AS now_function;

-- 10. LIMIT句による件数制限
-- 最初の5件のみ取得
SELECT * 
FROM workshop.students
LIMIT 5;