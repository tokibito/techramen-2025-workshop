-- 演習問題の解答例
-- ==================

-- 問題1: 特定クラスの生徒一覧
-- 1年1組の生徒を学籍番号順に表示
SELECT 
    s.student_number AS 学籍番号,
    s.last_name || ' ' || s.first_name AS 姓名,
    CASE 
        WHEN s.gender = 'M' THEN '男'
        WHEN s.gender = 'F' THEN '女'
    END AS 性別
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
WHERE c.grade = 1 AND c.class_number = 1
ORDER BY s.student_number;

-- 問題2: 高得点者の抽出
-- 1学期中間テストで90点以上を取った生徒
SELECT 
    s.last_name || ' ' || s.first_name AS 生徒名,
    sub.subject_name AS 科目,
    sc.score AS 点数
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
INNER JOIN workshop.exams e ON sc.exam_id = e.exam_id
WHERE e.exam_number = 1  -- 1学期中間テスト
  AND sc.score >= 90
ORDER BY sc.score DESC, s.student_id, sub.subject_id;

-- 問題3: 成績の並び替え
-- 2年生の数学の成績（点数の高い順、欠席者は最後）
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS 生徒名,
    c.class_name AS クラス,
    sc.score AS 点数,
    CASE 
        WHEN sc.is_absent = TRUE THEN '欠席'
        WHEN sc.score IS NULL THEN '未記録'
        ELSE '出席'
    END AS 出欠状況
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.subject_id = 2  -- 数学
    AND sc.exam_id = 1     -- 1学期中間テスト
WHERE c.grade = 2
ORDER BY sc.score DESC NULLS LAST;

-- 問題4: 全生徒の成績一覧
-- すべての生徒の国語の成績（未受験も表示）
SELECT 
    s.student_id,
    s.last_name || ' ' || s.first_name AS 生徒名,
    c.class_name AS クラス,
    COALESCE(sc.score::text, '未受験') AS 成績,
    CASE 
        WHEN sc.is_absent = TRUE THEN '欠席'
        WHEN sc.score IS NOT NULL THEN '出席'
        ELSE '未受験'
    END AS 受験状況
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LEFT JOIN workshop.scores sc 
    ON s.student_id = sc.student_id
    AND sc.subject_id = 1  -- 国語
    AND sc.exam_id = 1     -- 1学期中間テスト
ORDER BY c.grade, c.class_number, s.student_id;

-- 問題5: クラス別成績表
-- 各クラスの各科目の平均点（科目を横に並べて表示）
SELECT 
    c.class_name AS クラス,
    ROUND(AVG(CASE WHEN sub.subject_name = '国語' THEN sc.score END), 1) AS 国語,
    ROUND(AVG(CASE WHEN sub.subject_name = '数学' THEN sc.score END), 1) AS 数学,
    ROUND(AVG(CASE WHEN sub.subject_name = '英語' THEN sc.score END), 1) AS 英語,
    ROUND(AVG(CASE WHEN sub.subject_name = '理科' THEN sc.score END), 1) AS 理科,
    ROUND(AVG(CASE WHEN sub.subject_name = '社会' THEN sc.score END), 1) AS 社会,
    ROUND(AVG(sc.score), 1) AS 全科目平均
FROM workshop.classes c
INNER JOIN workshop.students s ON c.class_id = s.class_id
LEFT JOIN workshop.scores sc ON s.student_id = sc.student_id AND sc.exam_id = 1
LEFT JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.score IS NOT NULL
GROUP BY c.grade, c.class_number, c.class_name
ORDER BY c.grade, c.class_number;

-- 問題6: 同点の生徒ペア
-- 同じテストの同じ科目で同じ点数を取った生徒のペア
SELECT 
    e.exam_name AS テスト名,
    sub.subject_name AS 科目,
    sc1.score AS 点数,
    s1.last_name || ' ' || s1.first_name AS 生徒1,
    s2.last_name || ' ' || s2.first_name AS 生徒2
FROM workshop.scores sc1
INNER JOIN workshop.scores sc2 
    ON sc1.subject_id = sc2.subject_id 
    AND sc1.exam_id = sc2.exam_id
    AND sc1.score = sc2.score
    AND sc1.student_id < sc2.student_id
INNER JOIN workshop.students s1 ON sc1.student_id = s1.student_id
INNER JOIN workshop.students s2 ON sc2.student_id = s2.student_id
INNER JOIN workshop.subjects sub ON sc1.subject_id = sub.subject_id
INNER JOIN workshop.exams e ON sc1.exam_id = e.exam_id
WHERE sc1.score IS NOT NULL
ORDER BY e.exam_number, sub.subject_id, sc1.score DESC;

-- 問題7: 成績分布
-- 各科目の点数帯別人数（1学期中間テスト）
SELECT 
    sub.subject_name AS 科目,
    COUNT(CASE WHEN sc.score >= 90 THEN 1 END) AS "90点以上",
    COUNT(CASE WHEN sc.score >= 80 AND sc.score < 90 THEN 1 END) AS "80-89点",
    COUNT(CASE WHEN sc.score >= 70 AND sc.score < 80 THEN 1 END) AS "70-79点",
    COUNT(CASE WHEN sc.score >= 60 AND sc.score < 70 THEN 1 END) AS "60-69点",
    COUNT(CASE WHEN sc.score < 60 THEN 1 END) AS "60点未満",
    COUNT(sc.score) AS 受験者数,
    ROUND(AVG(sc.score), 1) AS 平均点
FROM workshop.subjects sub
LEFT JOIN workshop.scores sc 
    ON sub.subject_id = sc.subject_id 
    AND sc.exam_id = 1
    AND sc.score IS NOT NULL
GROUP BY sub.subject_id, sub.subject_name
ORDER BY sub.subject_id;

-- 問題8: 学年別集計
-- 各学年の各科目の平均点、最高点、最低点（学年全体の総合平均も表示）
SELECT 
    CASE 
        WHEN GROUPING(c.grade) = 1 THEN '全学年'
        ELSE c.grade::text || '年'
    END AS 学年,
    CASE 
        WHEN GROUPING(sub.subject_name) = 1 THEN '全科目'
        ELSE sub.subject_name
    END AS 科目,
    COUNT(sc.score) AS 受験者数,
    ROUND(AVG(sc.score), 1) AS 平均点,
    MAX(sc.score) AS 最高点,
    MIN(sc.score) AS 最低点
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
GROUP BY ROLLUP(c.grade, sub.subject_name)
ORDER BY c.grade NULLS LAST, sub.subject_name NULLS LAST;

-- 問題9: 成績推移分析
-- 特定の生徒（student_id = 1）の全テストにおける各科目の成績推移
SELECT 
    sub.subject_name AS 科目,
    MAX(CASE WHEN e.exam_number = 1 THEN sc.score END) AS "1学期中間",
    MAX(CASE WHEN e.exam_number = 2 THEN sc.score END) AS "1学期期末",
    MAX(CASE WHEN e.exam_number = 3 THEN sc.score END) AS "2学期中間",
    MAX(CASE WHEN e.exam_number = 4 THEN sc.score END) AS "2学期期末",
    MAX(CASE WHEN e.exam_number = 5 THEN sc.score END) AS "3学期期末",
    ROUND(AVG(sc.score), 1) AS 平均点
FROM workshop.subjects sub
LEFT JOIN workshop.scores sc 
    ON sub.subject_id = sc.subject_id 
    AND sc.student_id = 1
LEFT JOIN workshop.exams e ON sc.exam_id = e.exam_id
GROUP BY sub.subject_id, sub.subject_name
ORDER BY sub.subject_id;

-- 問題10: 総合ランキング
-- 1学期中間テストの5教科合計点で上位10名（同点は同順位）
WITH total_scores AS (
    SELECT 
        s.student_id,
        s.last_name || ' ' || s.first_name AS student_name,
        c.class_name,
        SUM(sc.score) AS total_score,
        COUNT(sc.score) AS subject_count
    FROM workshop.students s
    INNER JOIN workshop.classes c ON s.class_id = c.class_id
    INNER JOIN workshop.scores sc ON s.student_id = sc.student_id
    WHERE sc.exam_id = 1
      AND sc.score IS NOT NULL
    GROUP BY s.student_id, s.last_name, s.first_name, c.class_name
    HAVING COUNT(sc.score) = 5  -- 5教科すべて受験した生徒のみ
)
SELECT 
    RANK() OVER (ORDER BY total_score DESC) AS 順位,
    student_name AS 生徒名,
    class_name AS クラス,
    total_score AS 合計点,
    ROUND(total_score / 5.0, 1) AS 平均点
FROM total_scores
ORDER BY 順位
LIMIT 10;