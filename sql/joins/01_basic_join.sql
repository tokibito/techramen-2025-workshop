-- JOIN編：基本的なINNER JOIN
-- 生徒とクラスを結合する

-- 生徒の名前とクラス名を一緒に取得
SELECT 
    students.name AS "生徒名",
    classes.grade AS "学年",
    classes.class_name AS "クラス名"
FROM students
INNER JOIN classes ON students.class_id = classes.class_id
ORDER BY classes.grade, classes.class_name, students.name
LIMIT 10;