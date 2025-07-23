-- GROUP BY編：クラスごとの集計
-- GROUP BYで分類して集計

-- クラスごとの平均点を計算
SELECT 
    classes.grade AS "学年",
    classes.class_name AS "クラス",
    AVG(scores.score) AS "平均点"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
INNER JOIN classes ON students.class_id = classes.class_id
WHERE scores.exam_id = 1  -- 1学期中間テスト
GROUP BY classes.class_id, classes.grade, classes.class_name
ORDER BY classes.grade, classes.class_name;