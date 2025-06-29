-- SQL JOIN編: INNER JOIN（内部結合）
-- ===================================
-- 目的: INNER JOINの基本的な使い方と応用を学習
-- INNER JOIN: 両方のテーブルに存在するデータのみを結合

-- 1. 基本的なINNER JOIN
-- 生徒とその所属学級を結合
SELECT 
    s.student_id,
    s.student_number,
    s.last_name,
    s.first_name,
    c.class_name,
    c.grade
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id;

-- 2. INNER JOINの省略記法
-- "INNER"は省略可能
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name
FROM workshop.students s
JOIN workshop.classes c ON s.class_id = c.class_id;

-- 3. 3つのテーブルを結合
-- 生徒、成績、教科を結合
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score,
    sc.is_absent
FROM workshop.students s
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1;  -- 1学期中間テスト

-- 4. WHERE句との組み合わせ
-- 1年生の数学の成績を表示
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    sub.subject_name,
    sc.score
FROM workshop.students s
INNER JOIN workshop.classes c 
    ON s.class_id = c.class_id
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE c.grade = 1
  AND sub.subject_name = '数学'
  AND sc.exam_id = 1;

-- 5. 結合とソートの組み合わせ
-- クラスごとの生徒を姓名順に表示
SELECT 
    c.class_name,
    s.student_number,
    s.last_name,
    s.first_name
FROM workshop.students s
INNER JOIN workshop.classes c 
    ON s.class_id = c.class_id
ORDER BY c.grade, c.class_number, s.last_name, s.first_name;

-- 6. 結合結果の集計
-- クラスごとの平均点
SELECT 
    c.class_name,
    sub.subject_name,
    COUNT(sc.score_id) AS student_count,
    AVG(sc.score) AS avg_score,
    MAX(sc.score) AS max_score,
    MIN(sc.score) AS min_score
FROM workshop.classes c
INNER JOIN workshop.students s 
    ON c.class_id = s.class_id
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
  AND sc.score IS NOT NULL
GROUP BY c.class_name, sub.subject_name
ORDER BY c.class_name, sub.subject_name;

-- 7. 自己結合（セルフジョイン）
-- 同じクラスの生徒ペアを表示
SELECT 
    s1.last_name || ' ' || s1.first_name AS student1,
    s2.last_name || ' ' || s2.first_name AS student2,
    c.class_name
FROM workshop.students s1
INNER JOIN workshop.students s2 
    ON s1.class_id = s2.class_id 
    AND s1.student_id < s2.student_id
INNER JOIN workshop.classes c 
    ON s1.class_id = c.class_id
WHERE c.grade = 1  -- 1年生のみ
ORDER BY c.class_name, student1, student2
LIMIT 10;

-- 8. 複雑な結合条件
-- 80点以上を取った生徒とその教科
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    sub.subject_name,
    sc.score,
    e.exam_name
FROM workshop.students s
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.score >= 80
INNER JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
INNER JOIN workshop.classes c 
    ON s.class_id = c.class_id
INNER JOIN workshop.exams e 
    ON sc.exam_id = e.exam_id
ORDER BY e.exam_number, sc.score DESC;

-- 9. USINGを使った結合（列名が同じ場合）
-- class_idという共通の列名を使用
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name
FROM workshop.students s
INNER JOIN workshop.classes c USING (class_id);

-- 10. 全教科の成績がある生徒のみ表示
-- 5教科すべての成績が登録されている生徒
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS student_name,
    COUNT(DISTINCT sc.subject_id) AS subject_count,
    AVG(sc.score) AS avg_score
FROM workshop.students s
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN workshop.exams e 
    ON sc.exam_id = e.exam_id
WHERE e.exam_number = 1  -- 1学期中間テスト
  AND sc.score IS NOT NULL
GROUP BY s.student_id, s.last_name, s.first_name
HAVING COUNT(DISTINCT sc.subject_id) = 5  -- 5教科すべて
ORDER BY avg_score DESC;

-- 11. 時系列データの結合
-- 各テストでの成績推移
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    e.exam_name,
    e.exam_date,
    sc.score
FROM workshop.students s
INNER JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
INNER JOIN workshop.subjects sub 
    ON sc.subject_id = sub.subject_id
INNER JOIN workshop.exams e 
    ON sc.exam_id = e.exam_id
WHERE s.student_id = 1  -- 特定の生徒
  AND sc.score IS NOT NULL
ORDER BY sub.subject_id, e.exam_number;