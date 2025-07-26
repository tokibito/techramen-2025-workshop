============================
GROUP BY編：データを集計する
============================

GROUP BYとは
============

GROUP BYは、データをグループ化して集計するための機能です。

例えば以下のようなことができます：

* クラスごとの平均点を計算
* 教科ごとの最高点・最低点を確認
* 生徒ごとの合計点でランキング作成

集計の基本
==========

まずは基本的な集計関数を見てみましょう。

よく使う集計関数
----------------

.. code-block:: sql

   -- 全生徒の数学の平均点
   SELECT 
       AVG(score) AS "平均点"
   FROM scores
   INNER JOIN subjects ON scores.subject_id = subjects.subject_id
   WHERE subjects.subject_name = '数学'
     AND scores.exam_id = 1;

主な集計関数：

* ``COUNT()`` - 件数を数える
* ``SUM()`` - 合計を計算
* ``AVG()`` - 平均を計算
* ``MAX()`` - 最大値を取得
* ``MIN()`` - 最小値を取得

GROUP BYで分類して集計
----------------------

クラスごとの平均点を計算してみます。

GROUP BYの動作イメージ：

.. mermaid::

   graph TD
       subgraph "元データ"
           D1[1年1組 青木 80点]
           D2[1年1組 石田 75点]
           D3[1年1組 上田 85点]
           D4[1年2組 佐々木 90点]
           D5[1年2組 島田 85点]
           D6[1年2組 杉山 80点]
       end
       
       subgraph "GROUP BY classes.class_id"
           G1[1年1組グループ<br/>80, 75, 85]
           G2[1年2組グループ<br/>90, 85, 80]
       end
       
       subgraph "集計結果"
           R1[1年1組 平均: 80.0]
           R2[1年2組 平均: 85.0]
       end
       
       D1 --> G1
       D2 --> G1
       D3 --> G1
       D4 --> G2
       D5 --> G2
       D6 --> G2
       
       G1 --> R1
       G2 --> R2
       
       style D1 fill:#e8f4fd
       style D2 fill:#e8f4fd
       style D3 fill:#e8f4fd
       style D4 fill:#ffeaa7
       style D5 fill:#ffeaa7
       style D6 fill:#ffeaa7

実際のSQLクエリ：

.. code-block:: sql

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

ポイント：

* ``GROUP BY`` で指定したカラムごとにグループ化
* SELECTに含める非集計カラムは、すべてGROUP BYに含める必要がある

実用的な集計例
==============

教科別の成績分析
----------------

各教科の平均点、最高点、最低点を一度に取得：

.. code-block:: sql

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

生徒の成績ランキング
--------------------

生徒ごとの5教科合計点でランキングを作成：

.. code-block:: sql

   SELECT 
       students.last_name || ' ' || students.first_name AS "生徒名",
       classes.grade AS "学年",
       classes.class_name AS "クラス",
       SUM(scores.score) AS "合計点"
   FROM scores
   INNER JOIN students ON scores.student_id = students.student_id
   INNER JOIN classes ON students.class_id = classes.class_id
   WHERE scores.exam_id = 1
   GROUP BY students.student_id, students.last_name, students.first_name, classes.class_id, classes.grade, classes.class_name
   ORDER BY SUM(scores.score) DESC
   LIMIT 10;

HAVINGで集計結果を絞り込む
===========================

平均点が70点以上の生徒のみを表示：

.. code-block:: sql

   SELECT 
       students.last_name || ' ' || students.first_name AS "生徒名",
       AVG(scores.score) AS "平均点"
   FROM scores
   INNER JOIN students ON scores.student_id = students.student_id
   WHERE scores.exam_id = 1
   GROUP BY students.student_id, students.last_name, students.first_name
   HAVING AVG(scores.score) >= 70
   ORDER BY AVG(scores.score) DESC;

``WHERE`` と ``HAVING`` の違い：

* ``WHERE`` - グループ化前のデータを絞り込む
* ``HAVING`` - グループ化後の集計結果を絞り込む

実践的な応用例
==============

クラス別成績表の作成
--------------------

クラスごと、教科ごとの平均点を一覧表示します。

複数カラムでのGROUP BY：

.. mermaid::

   graph TD
       subgraph "元データ（一部）"
           D1[1年1組 国語 80点]
           D2[1年1組 国語 75点]
           D3[1年1組 数学 85点]
           D4[1年1組 数学 90点]
           D5[1年2組 国語 70点]
           D6[1年2組 国語 80点]
       end
       
       subgraph "GROUP BY class_id, subject_id"
           G1[1年1組・国語<br/>80, 75]
           G2[1年1組・数学<br/>85, 90]
           G3[1年2組・国語<br/>70, 80]
       end
       
       subgraph "集計結果"
           R1[1年1組 国語 平均: 77.5]
           R2[1年1組 数学 平均: 87.5]
           R3[1年2組 国語 平均: 75.0]
       end
       
       D1 --> G1
       D2 --> G1
       D3 --> G2
       D4 --> G2
       D5 --> G3
       D6 --> G3
       
       G1 --> R1
       G2 --> R2
       G3 --> R3

実際のSQLクエリ：

.. code-block:: sql

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

``ROUND()`` 関数で小数点第1位まで表示しています。

実践演習
========

以下の問題にチャレンジしてみてください：

**演習1**: 各クラスの生徒数を表示してください

.. code-block:: sql

   -- ヒント: students, classesをJOINして、COUNT()を使う
   SELECT ...

**演習2**: 数学で80点以上を取った生徒が最も多いクラスを見つけてください

.. code-block:: sql

   -- ヒント: WHERE句で絞り込んでからGROUP BY、ORDER BYで並び替え
   SELECT ...

まとめ
======

GROUP BY編で学んだこと：

* ``GROUP BY`` でデータをグループ化して集計できる
* ``COUNT()``、``SUM()``、``AVG()`` などの集計関数を使う
* ``HAVING`` で集計結果を絞り込める
* JOINと組み合わせることで、複雑な集計も可能

これでJOINとGROUP BYの基本をマスターしました。実際の業務でも頻繁に使う重要な機能です。