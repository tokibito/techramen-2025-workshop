-- JOIN編：複数テーブルの結合
-- 4つのテーブルを結合する例

-- どのクラスの誰が、どのテストで、どの教科で何点取ったか
SELECT 
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    students.name AS "生徒名",
    subjects.subject_name AS "教科",
    exams.exam_name AS "テスト名",
    scores.score AS "点数"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
INNER JOIN exams ON scores.exam_id = exams.exam_id
INNER JOIN classes ON students.class_id = classes.class_id
WHERE classes.grade = 2  -- 2年生のみ
  AND exams.exam_id = 1  -- 1学期中間テスト
ORDER BY classes.class_name, students.name, subjects.subject_id;