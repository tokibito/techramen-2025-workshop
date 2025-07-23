-- GROUP BY編：HAVINGで集計結果を絞り込む
-- 平均点が70点以上の生徒のみを表示

SELECT 
    students.name AS "生徒名",
    AVG(scores.score) AS "平均点"
FROM scores
INNER JOIN students ON scores.student_id = students.student_id
WHERE scores.exam_id = 1
GROUP BY students.student_id, students.name
HAVING AVG(scores.score) >= 70
ORDER BY AVG(scores.score) DESC;