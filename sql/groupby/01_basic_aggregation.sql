-- GROUP BY編：基本的な集計
-- よく使う集計関数

-- 全生徒の数学の平均点
SELECT 
    AVG(score) AS "平均点"
FROM scores
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
WHERE subjects.subject_name = '数学'
  AND scores.exam_id = 1;