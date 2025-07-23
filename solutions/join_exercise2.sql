-- JOIN編 演習2の解答
-- 問題：数学の成績が80点以上の生徒の名前とクラスを取得してください

SELECT 
    students.name AS "生徒名",
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    scores.score AS "数学の点数"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
INNER JOIN classes ON students.class_id = classes.class_id
WHERE subjects.subject_name = '数学'
  AND scores.score >= 80
ORDER BY classes.grade, classes.class_name, students.name;