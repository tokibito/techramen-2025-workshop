-- GROUP BY編：教科別の成績分析
-- 各教科の平均点、最高点、最低点を一度に取得

SELECT 
    subjects.subject_name AS "教科",
    COUNT(scores.score) AS "受験者数",
    AVG(scores.score) AS "平均点",
    MAX(scores.score) AS "最高点",
    MIN(scores.score) AS "最低点"
FROM scores
INNER JOIN subjects ON scores.subject_id = subjects.subject_id
WHERE scores.exam_id = 1
GROUP BY subjects.subject_id, subjects.subject_name
ORDER BY subjects.subject_id;