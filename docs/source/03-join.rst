========================
JOIN編：テーブルを結合する
========================

なぜJOINが必要か
================

前章で見たように、データベースでは情報を複数のテーブルに分けて管理しています。

例えば「2年B組の田中さんの数学の点数」を知りたいとき、以下の情報が必要です：

* 生徒の名前（studentsテーブル）
* クラス名（classesテーブル）
* 教科名（subjectsテーブル）
* 点数（scoresテーブル）

これらを別々に取得するのは大変ですよね。JOINを使えば、一度のクエリで全部取得できます。

INNER JOINの基本
================

まずは最も基本的なINNER JOINから始めましょう。

生徒とクラスを結合する
----------------------

生徒の名前とクラス名を一緒に取得してみます。

まず、どのようにテーブルが結合されるかを図で確認しましょう：

.. mermaid::

   graph LR
       subgraph "studentsテーブル"
           S1[student_id: 1<br/>name: 山田太郎<br/>class_id: 1]
           S2[student_id: 2<br/>name: 佐藤花子<br/>class_id: 1]
           S3[student_id: 3<br/>name: 鈴木一郎<br/>class_id: 2]
       end
       
       subgraph "classesテーブル"
           C1[class_id: 1<br/>grade: 1<br/>class_name: A]
           C2[class_id: 2<br/>grade: 1<br/>class_name: B]
       end
       
       S1 -.->|class_id = 1| C1
       S2 -.->|class_id = 1| C1
       S3 -.->|class_id = 2| C2
       
       style S1 fill:#e8f4fd
       style S2 fill:#e8f4fd
       style S3 fill:#e8f4fd
       style C1 fill:#ffeaa7
       style C2 fill:#ffeaa7

この図のように、studentsテーブルのclass_idとclassesテーブルのclass_idが一致するレコードが結合されます。

実際のSQLクエリ：

.. code-block:: sql

   SELECT 
       students.name AS "生徒名",
       classes.grade AS "学年",
       classes.class_name AS "クラス名"
   FROM students
   INNER JOIN classes ON students.class_id = classes.class_id
   ORDER BY classes.grade, classes.class_name, students.name
   LIMIT 10;

このクエリのポイント：

* ``INNER JOIN`` で2つのテーブルを結合
* ``ON`` でどのカラムで結合するかを指定
* ``AS`` で分かりやすい列名に変更

成績データを結合する
--------------------

次は、生徒の成績データも含めて取得してみましょう：

.. code-block:: sql

   SELECT 
       students.name AS "生徒名",
       subjects.subject_name AS "教科",
       scores.score AS "点数"
   FROM scores
   INNER JOIN students ON scores.student_id = students.student_id
   INNER JOIN subjects ON scores.subject_id = subjects.subject_id
   WHERE scores.exam_id = 1  -- 1学期中間テスト
   ORDER BY students.name, subjects.subject_id
   LIMIT 15;

複数テーブルの結合
==================

実際の業務では、3つ以上のテーブルを結合することがよくあります。

4つのテーブルを結合する例
-------------------------

「どのクラスの誰が、どのテストで、どの教科で何点取ったか」を全部まとめて取得します。

複数テーブルの結合イメージ：

.. mermaid::

   graph TB
       subgraph "結合の流れ"
           scores[scoresテーブル<br/>中心となるテーブル]
           students[studentsテーブル<br/>生徒情報]
           subjects[subjectsテーブル<br/>教科情報]
           exams[examsテーブル<br/>テスト情報]
           classes[classesテーブル<br/>クラス情報]
           
           scores -->|student_id| students
           scores -->|subject_id| subjects
           scores -->|exam_id| exams
           students -->|class_id| classes
       end
       
       style scores fill:#ff7675
       style students fill:#74b9ff
       style subjects fill:#a29bfe
       style exams fill:#fd79a8
       style classes fill:#fdcb6e

scoresテーブルを中心に、各IDで関連するテーブルを結合していきます：

.. code-block:: sql

   SELECT 
       classes.grade AS "学年",
       classes.class_name AS "クラス",
       students.name AS "生徒名",
       subjects.subject_name AS "教科",
       exams.exam_name AS "テスト名",
       scores.score AS "点数"
   FROM scores
   INNER JOIN students ON scores.student_id = students.student_id
   INNER JOIN subjects ON scores.subject_id = subjects.subject_id
   INNER JOIN exams ON scores.exam_id = exams.exam_id
   INNER JOIN classes ON students.class_id = classes.class_id
   WHERE classes.grade = 2  -- 2年生のみ
     AND exams.exam_id = 1  -- 1学期中間テスト
   ORDER BY classes.class_name, students.name, subjects.subject_id;

このように、JOINを使うことで複数のテーブルから必要な情報を効率的に取得できます。

実践演習
========

以下の問題にチャレンジしてみてください：

**演習1**: 1年A組の生徒一覧を取得してください（生徒名のみ）

.. code-block:: sql

   -- ヒント: studentsとclassesをJOINして、WHERE句で絞り込み
   SELECT ...

**演習2**: 数学の成績が80点以上の生徒の名前とクラスを取得してください

.. code-block:: sql

   -- ヒント: scores, students, subjects, classesの4つをJOIN
   SELECT ...

まとめ
======

JOIN編で学んだこと：

* テーブルを結合することで、複数の情報を一度に取得できる
* ``INNER JOIN`` は両方のテーブルに存在するデータのみを結合
* ``ON`` 句で結合条件を指定する
* 複数のテーブルも連続してJOINできる

次はGROUP BY編で、データの集計方法を学びます。