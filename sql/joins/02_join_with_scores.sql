-- JOIN編：成績データを結合する
-- 生徒の成績データも含めて取得

-- 生徒名、教科、点数を取得（1学期中間テスト）
SELECT 
    students.name AS "生徒名",
    subjects.subject_name AS "教科",
    scores.score AS "点数"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
WHERE scores.exam_id = 1  -- 1学期中間テスト
ORDER BY students.name, subjects.subject_id
LIMIT 15;