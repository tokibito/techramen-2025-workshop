-- GROUP BY編：クラス別成績表の作成
-- クラスごと、教科ごとの平均点を一覧表示

SELECT 
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    subjects.subject_name AS "教科",
    ROUND(AVG(scores.score), 1) AS "平均点"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN classes ON students.class_id = classes.class_id
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
WHERE scores.exam_id = 1
GROUP BY 
    classes.class_id, classes.grade, classes.class_name,
    subjects.subject_id, subjects.subject_name
ORDER BY 
    classes.grade, classes.class_name, subjects.subject_id;