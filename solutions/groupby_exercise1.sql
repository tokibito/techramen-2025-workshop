-- GROUP BY編 演習1の解答
-- 問題：各クラスの生徒数を表示してください

SELECT 
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    COUNT(students.student_id) AS "生徒数"
FROM students
INNER JOIN classes ON students.class_id = classes.class_id
GROUP BY classes.class_id, classes.grade, classes.class_name
ORDER BY classes.grade, classes.class_name;