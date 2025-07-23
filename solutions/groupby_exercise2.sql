-- GROUP BY編 演習2の解答
-- 問題：数学で80点以上を取った生徒が最も多いクラスを見つけてください

SELECT 
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    COUNT(students.student_id) AS "80点以上の生徒数"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
INNER JOIN classes ON students.class_id = classes.class_id
WHERE subjects.subject_name = '数学'
  AND scores.score >= 80
GROUP BY classes.class_id, classes.grade, classes.class_name
ORDER BY COUNT(students.student_id) DESC
LIMIT 1;