-- JOIN編 演習1の解答
-- 問題：1年A組の生徒一覧を取得してください（生徒名のみ）

SELECT 
    students.name AS "生徒名"
FROM students
INNER JOIN classes ON students.class_id = classes.class_id
WHERE classes.grade = 1 
  AND classes.class_name = 'A'
ORDER BY students.name;