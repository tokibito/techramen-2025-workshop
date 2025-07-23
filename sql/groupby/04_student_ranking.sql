-- GROUP BY編：生徒の成績ランキング
-- 生徒ごとの5教科合計点でランキングを作成

SELECT 
    students.name AS "生徒名",
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    SUM(scores.score) AS "合計点"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN classes ON students.class_id = classes.class_id
WHERE scores.exam_id = 1
GROUP BY students.student_id, students.name, classes.class_id, classes.grade, classes.class_name
ORDER BY SUM(scores.score) DESC
LIMIT 10;