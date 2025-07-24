.. _sql-cheatsheet:

PostgreSQL SQLチートシート
==========================

.. contents:: 目次
   :local:
   :depth: 2

基本のSELECT文
--------------

基本構文
~~~~~~~~

.. code-block:: sql

   -- 全カラムを選択
   SELECT * FROM テーブル名;

   -- 特定のカラムを選択
   SELECT カラム1, カラム2 FROM テーブル名;

   -- カラムに別名を付ける
   SELECT カラム1 AS "別名1", カラム2 AS "別名2" FROM テーブル名;

   -- 重複を除外
   SELECT DISTINCT カラム名 FROM テーブル名;

WHERE句（条件指定）
-------------------

比較演算子
~~~~~~~~~~

.. code-block:: sql

   -- 等しい
   SELECT * FROM students WHERE grade = 1;

   -- 等しくない
   SELECT * FROM students WHERE grade != 1;
   SELECT * FROM students WHERE grade <> 1;

   -- より大きい、以上
   SELECT * FROM scores WHERE score > 80;
   SELECT * FROM scores WHERE score >= 80;

   -- より小さい、以下
   SELECT * FROM scores WHERE score < 60;
   SELECT * FROM scores WHERE score <= 60;

   -- 範囲指定
   SELECT * FROM scores WHERE score BETWEEN 60 AND 80;

   -- リストに含まれる
   SELECT * FROM students WHERE grade IN (1, 2);

   -- NULLの判定
   SELECT * FROM students WHERE remarks IS NULL;
   SELECT * FROM students WHERE remarks IS NOT NULL;

文字列の検索（PostgreSQL）
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- 部分一致（%は任意の0文字以上）
   SELECT * FROM students WHERE name LIKE '田中%';
   SELECT * FROM students WHERE name LIKE '%子';
   SELECT * FROM students WHERE name LIKE '%田%';

   -- 文字数指定（_は任意の1文字）
   SELECT * FROM students WHERE name LIKE '田_';

   -- 大文字小文字を区別しない（ILIKE）
   SELECT * FROM students WHERE name ILIKE 'tanaka%';

   -- 正規表現（~演算子）
   SELECT * FROM students WHERE name ~ '^田中';  -- 田中で始まる
   SELECT * FROM students WHERE name ~ '子$';    -- 子で終わる

複数条件の組み合わせ
~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- AND（両方満たす）
   SELECT * FROM students WHERE grade = 1 AND class = 'A';

   -- OR（どちらか満たす）
   SELECT * FROM students WHERE grade = 1 OR grade = 2;

   -- NOT（条件を満たさない）
   SELECT * FROM students WHERE NOT grade = 3;

   -- 複雑な条件（括弧で優先順位を明確に）
   SELECT * FROM students 
   WHERE (grade = 1 OR grade = 2) AND class = 'A';

ORDER BY（並び替え）
--------------------

.. code-block:: sql

   -- 昇順（小→大、デフォルト）
   SELECT * FROM students ORDER BY student_number;
   SELECT * FROM students ORDER BY student_number ASC;

   -- 降順（大→小）
   SELECT * FROM scores ORDER BY score DESC;

   -- 複数キーでの並び替え
   SELECT * FROM students 
   ORDER BY grade ASC, class ASC, student_number ASC;

   -- NULLの扱い（PostgreSQL固有）
   SELECT * FROM students 
   ORDER BY remarks NULLS FIRST;  -- NULLを先頭に
   SELECT * FROM students 
   ORDER BY remarks NULLS LAST;   -- NULLを末尾に（デフォルト）

LIMIT/OFFSET（件数制限）
------------------------

.. code-block:: sql

   -- 最初の10件
   SELECT * FROM students LIMIT 10;

   -- 11件目から10件
   SELECT * FROM students LIMIT 10 OFFSET 10;

   -- 成績上位5名
   SELECT * FROM scores 
   ORDER BY score DESC 
   LIMIT 5;

集計関数
--------

基本的な集計関数
~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- 件数
   SELECT COUNT(*) FROM students;
   SELECT COUNT(student_id) FROM students;
   SELECT COUNT(DISTINCT grade) FROM students;

   -- 合計
   SELECT SUM(score) FROM scores;

   -- 平均
   SELECT AVG(score) FROM scores;
   SELECT ROUND(AVG(score)::numeric, 1) FROM scores;  -- 小数点第1位で四捨五入

   -- 最大値・最小値
   SELECT MAX(score) FROM scores;
   SELECT MIN(score) FROM scores;

PostgreSQL固有の集計関数
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- 文字列の集約
   SELECT string_agg(name, ', ' ORDER BY student_number) 
   FROM students WHERE grade = 1;

   -- 配列への集約
   SELECT array_agg(score ORDER BY score DESC) 
   FROM scores WHERE student_id = 1;

   -- 標準偏差・分散
   SELECT 
       STDDEV(score) as "standard_deviation",
       VARIANCE(score) as "variance"
   FROM scores;

GROUP BY（グループ化）
----------------------

.. code-block:: sql

   -- 学年別の生徒数
   SELECT grade, COUNT(*) as "student_count"
   FROM students
   GROUP BY grade;

   -- 教科別の平均点
   SELECT subject_id, AVG(score) as "avg_score"
   FROM scores
   GROUP BY subject_id;

   -- 複数カラムでグループ化
   SELECT grade, class, COUNT(*) as "student_count"
   FROM students
   GROUP BY grade, class
   ORDER BY grade, class;

   -- 集計結果に別名を付ける
   SELECT 
       s.subject_name,
       COUNT(*) as "test_count",
       AVG(sc.score) as "avg_score",
       MAX(sc.score) as "max_score",
       MIN(sc.score) as "min_score"
   FROM scores sc
   JOIN subjects s ON sc.subject_id = s.subject_id
   GROUP BY s.subject_id, s.subject_name;

HAVING（集計結果の絞り込み）
----------------------------

.. code-block:: sql

   -- 平均点が70点以上の教科
   SELECT subject_id, AVG(score) as "avg_score"
   FROM scores
   GROUP BY subject_id
   HAVING AVG(score) >= 70;

   -- 生徒数が30人以上の学年
   SELECT grade, COUNT(*) as "student_count"
   FROM students
   GROUP BY grade
   HAVING COUNT(*) >= 30;

   -- WHEREとHAVINGの組み合わせ
   SELECT 
       student_id,
       AVG(score) as "avg_score"
   FROM scores
   WHERE test_id IN (1, 2, 3)  -- 最初の3回のテストのみ
   GROUP BY student_id
   HAVING AVG(score) >= 80     -- 平均80点以上
   ORDER BY avg_score DESC;

PostgreSQL便利な関数
--------------------

文字列関数
~~~~~~~~~~

.. code-block:: sql

   -- 文字列結合（||演算子）
   SELECT grade || '年' || class || '組' as "class_name" FROM students;

   -- CONCAT関数
   SELECT CONCAT(grade, '年', class, '組') as "class_name" FROM students;

   -- 文字列の長さ（日本語対応）
   SELECT name, LENGTH(name) as "byte_length" FROM students;
   SELECT name, CHAR_LENGTH(name) as "char_length" FROM students;

   -- 大文字・小文字変換
   SELECT UPPER(class), LOWER(class) FROM students;

   -- 文字列の切り出し
   SELECT SUBSTRING(name FROM 1 FOR 1) as "first_char" FROM students;
   SELECT LEFT(name, 1) as "first_char" FROM students;
   SELECT RIGHT(name, 1) as "last_char" FROM students;

   -- 空白の除去
   SELECT TRIM(name) FROM students;
   SELECT LTRIM(name), RTRIM(name) FROM students;

   -- 文字列の置換
   SELECT REPLACE(name, '田', '山') FROM students;

   -- 文字列の分割
   SELECT SPLIT_PART('2025-01-24', '-', 1) as "year";

数値関数
~~~~~~~~

.. code-block:: sql

   -- 四捨五入
   SELECT ROUND(95.456, 2);  -- 95.46
   SELECT ROUND(95.456);     -- 95

   -- 切り上げ・切り捨て
   SELECT CEIL(95.1), FLOOR(95.9);
   SELECT CEILING(95.1);  -- CEILと同じ

   -- 切り捨て（小数点以下の桁数指定）
   SELECT TRUNC(95.456, 2);  -- 95.45

   -- 絶対値
   SELECT ABS(score - 70) as "diff_from_70" FROM scores;

   -- べき乗・平方根
   SELECT POWER(2, 10);  -- 2の10乗
   SELECT SQRT(16);      -- 4

   -- 剰余
   SELECT MOD(10, 3);    -- 1
   SELECT 10 % 3;        -- 1（演算子）

日付・時刻関数
~~~~~~~~~~~~~~

.. code-block:: sql

   -- 現在の日時（PostgreSQL）
   SELECT CURRENT_DATE;              -- 日付のみ
   SELECT CURRENT_TIME;              -- 時刻のみ
   SELECT CURRENT_TIMESTAMP;         -- 日時
   SELECT NOW();                     -- 日時（CURRENT_TIMESTAMPと同じ）

   -- 日付の一部を取得
   SELECT 
       EXTRACT(YEAR FROM test_date) as "year",
       EXTRACT(MONTH FROM test_date) as "month",
       EXTRACT(DAY FROM test_date) as "day",
       EXTRACT(DOW FROM test_date) as "day_of_week"  -- 0=日曜
   FROM tests;

   -- DATE_PART関数（EXTRACTと同じ）
   SELECT DATE_PART('year', test_date) FROM tests;

   -- 日付の計算
   SELECT test_date + INTERVAL '7 days' FROM tests;
   SELECT test_date - INTERVAL '1 month' FROM tests;
   SELECT test_date + INTERVAL '1 year 2 months 3 days';

   -- 日付の差分
   SELECT AGE(CURRENT_DATE, '2000-01-01');  -- 期間を返す
   SELECT CURRENT_DATE - '2000-01-01';      -- 日数を返す

   -- 日付のフォーマット
   SELECT TO_CHAR(test_date, 'YYYY年MM月DD日') FROM tests;
   SELECT TO_CHAR(test_date, 'YYYY-MM-DD HH24:MI:SS');

型変換（キャスト）
~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- CAST関数
   SELECT CAST('123' AS INTEGER);
   SELECT CAST(123 AS TEXT);
   SELECT CAST('2025-01-24' AS DATE);

   -- ::演算子（PostgreSQL固有）
   SELECT '123'::INTEGER;
   SELECT 123::TEXT;
   SELECT '2025-01-24'::DATE;

   -- 数値の精度変換
   SELECT CAST(123.456 AS NUMERIC(5,2));  -- 123.46
   SELECT 123.456::NUMERIC(5,2);

条件分岐
--------

CASE式
~~~~~~

.. code-block:: sql

   -- 成績の評価
   SELECT 
       student_id,
       score,
       CASE 
           WHEN score >= 90 THEN '優'
           WHEN score >= 80 THEN '良'
           WHEN score >= 70 THEN '可'
           ELSE '不可'
       END as "evaluation"
   FROM scores;

   -- 学年の表示
   SELECT 
       name,
       CASE grade
           WHEN 1 THEN '1年生'
           WHEN 2 THEN '2年生'
           WHEN 3 THEN '3年生'
       END as "grade_name"
   FROM students;

COALESCE（NULL対応）
~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- NULLの場合にデフォルト値を使用
   SELECT 
       name,
       COALESCE(remarks, '特記事項なし') as "remarks"
   FROM students;

   -- 複数の値から最初の非NULL値を取得
   SELECT COALESCE(remarks, email, '情報なし') FROM students;

NULLIF
~~~~~~

.. code-block:: sql

   -- 特定の値をNULLに変換
   SELECT NULLIF(score, 0) FROM scores;  -- 0点をNULLに
   
   -- ゼロ除算の回避
   SELECT total / NULLIF(count, 0) as "average";

ウィンドウ関数（PostgreSQL）
----------------------------

ランキング関数
~~~~~~~~~~~~~~

.. code-block:: sql

   -- 順位付け（同じ値は同じ順位、次の順位は飛ぶ）
   SELECT 
       student_id,
       score,
       RANK() OVER (ORDER BY score DESC) as "rank"
   FROM scores;

   -- 順位付け（同じ値は同じ順位、次の順位は連続）
   SELECT 
       student_id,
       score,
       DENSE_RANK() OVER (ORDER BY score DESC) as "dense_rank"
   FROM scores;

   -- 連番（同じ値でも連番）
   SELECT 
       student_id,
       score,
       ROW_NUMBER() OVER (ORDER BY score DESC) as "row_num"
   FROM scores;

   -- パーセンタイル順位
   SELECT 
       student_id,
       score,
       PERCENT_RANK() OVER (ORDER BY score) as "percent_rank"
   FROM scores;

グループ内での順位
~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- 教科別の順位
   SELECT 
       student_id,
       subject_id,
       score,
       RANK() OVER (PARTITION BY subject_id ORDER BY score DESC) as "subject_rank"
   FROM scores;

   -- 学年・クラス別の成績順位
   SELECT 
       st.name,
       st.grade,
       st.class,
       AVG(sc.score) as "avg_score",
       RANK() OVER (
           PARTITION BY st.grade, st.class 
           ORDER BY AVG(sc.score) DESC
       ) as "class_rank"
   FROM students st
   JOIN scores sc ON st.student_id = sc.student_id
   GROUP BY st.student_id, st.name, st.grade, st.class;

移動集計
~~~~~~~~

.. code-block:: sql

   -- 累積合計
   SELECT 
       test_date,
       score,
       SUM(score) OVER (ORDER BY test_date) as "cumulative_score"
   FROM scores
   WHERE student_id = 1;

   -- 移動平均（前後1行を含む3行の平均）
   SELECT 
       test_date,
       score,
       AVG(score) OVER (
           ORDER BY test_date 
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) as "moving_avg"
   FROM scores;

   -- 直前の値を取得
   SELECT 
       test_date,
       score,
       LAG(score, 1) OVER (ORDER BY test_date) as "prev_score",
       score - LAG(score, 1) OVER (ORDER BY test_date) as "diff"
   FROM scores;

クエリの組み合わせ
------------------

サブクエリ
~~~~~~~~~~

.. code-block:: sql

   -- 平均点以上の生徒
   SELECT * FROM scores
   WHERE score > (SELECT AVG(score) FROM scores);

   -- 各教科の最高得点者
   SELECT * FROM scores s1
   WHERE score = (
       SELECT MAX(score) 
       FROM scores s2 
       WHERE s1.subject_id = s2.subject_id
   );

   -- EXISTS（存在確認）
   SELECT * FROM students s
   WHERE EXISTS (
       SELECT 1 FROM scores sc
       WHERE sc.student_id = s.student_id
       AND sc.score >= 90
   );

WITH句（共通テーブル式）
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- 各生徒の平均点を計算してから使用
   WITH student_averages AS (
       SELECT 
           student_id,
           AVG(score) as "avg_score"
       FROM scores
       GROUP BY student_id
   )
   SELECT 
       s.name,
       sa.avg_score
   FROM students s
   JOIN student_averages sa ON s.student_id = sa.student_id
   WHERE sa.avg_score >= 80
   ORDER BY sa.avg_score DESC;

   -- 複数のCTE
   WITH 
   high_scores AS (
       SELECT student_id, subject_id, score
       FROM scores
       WHERE score >= 80
   ),
   student_counts AS (
       SELECT student_id, COUNT(*) as "high_score_count"
       FROM high_scores
       GROUP BY student_id
   )
   SELECT 
       s.name,
       sc.high_score_count
   FROM students s
   JOIN student_counts sc ON s.student_id = sc.student_id
   WHERE sc.high_score_count >= 3;

UNION/INTERSECT/EXCEPT
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   -- 結果の結合（重複除去）
   SELECT name FROM students WHERE grade = 1
   UNION
   SELECT name FROM students WHERE class = 'A';

   -- 結果の結合（重複含む）
   SELECT name FROM students WHERE grade = 1
   UNION ALL
   SELECT name FROM students WHERE class = 'A';

   -- 共通部分
   SELECT student_id FROM scores WHERE subject_id = 1 AND score >= 80
   INTERSECT
   SELECT student_id FROM scores WHERE subject_id = 2 AND score >= 80;

   -- 差分
   SELECT student_id FROM students
   EXCEPT
   SELECT DISTINCT student_id FROM scores;