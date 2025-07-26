========================
演習問題の解説
========================

ここでは、各章で出題した演習問題の解答と解説を見ていきます。
実際に手を動かして理解を深めましょう。

JOIN編の演習問題
================

演習1：1年1組の生徒一覧
------------------------

**問題**: 1年1組の生徒一覧を取得してください（生徒名のみ）

**解答**:

.. code-block:: sql

   SELECT 
       students.last_name || ' ' || students.first_name AS "生徒名"
   FROM students
   INNER JOIN classes ON students.class_id = classes.class_id
   WHERE classes.grade = 1 
     AND classes.class_name = '1年1組'
   ORDER BY students.last_name, students.first_name;

**解説**:

この問題のポイントは以下の通りです：

1. **必要なテーブルの特定**: 生徒名（students）とクラス情報（classes）が必要
2. **結合条件**: ``students.class_id = classes.class_id`` でテーブルを結合
3. **絞り込み条件**: ``WHERE`` 句で学年とクラス名を指定
4. **並び順**: 生徒名でソートして見やすくする

よくある間違い：

* クラスIDで直接絞り込もうとする → クラスIDは内部的な値なので、学年とクラス名で絞り込む
* JOINを忘れてstudentsテーブルだけで取得しようとする

演習2：数学の高得点者
---------------------

**問題**: 数学の成績が80点以上の生徒の名前とクラスを取得してください

**解答**:

.. code-block:: sql

   SELECT 
       students.last_name || ' ' || students.first_name AS "生徒名",
       classes.grade AS "学年",
       classes.class_name AS "クラス",
       scores.score AS "数学の点数"
   FROM scores
   INNER JOIN students ON scores.student_id = students.student_id
   INNER JOIN subjects ON scores.subject_id = subjects.subject_id
   INNER JOIN classes ON students.class_id = classes.class_id
   WHERE subjects.subject_name = '数学'
     AND scores.score >= 80
   ORDER BY classes.grade, classes.class_name, students.last_name, students.first_name;

**解説**:

この問題は複数テーブルの結合が必要な実践的な例です：

1. **4つのテーブルを結合**:
   
   * scores（点数の情報）
   * students（生徒の情報）
   * subjects（教科の情報）
   * classes（クラスの情報）

2. **結合の順序**:
   
   * scoresを起点に各テーブルを結合
   * scoresとstudentsはstudent_idで結合
   * scoresとsubjectsはsubject_idで結合
   * studentsとclassesはclass_idで結合

3. **絞り込み条件**:
   
   * 教科名が「数学」
   * 点数が80点以上

実際に点数も表示することで、条件が正しく適用されているか確認できます。

GROUP BY編の演習問題
====================

演習1：クラスの生徒数
---------------------

**問題**: 各クラスの生徒数を表示してください

**解答**:

.. code-block:: sql

   SELECT 
       classes.grade AS "学年",
       classes.class_name AS "クラス",
       COUNT(students.student_id) AS "生徒数"
   FROM students
   INNER JOIN classes ON students.class_id = classes.class_id
   GROUP BY classes.class_id, classes.grade, classes.class_name
   ORDER BY classes.grade, classes.class_name;

**解説**:

GROUP BYの基本的な使い方を理解する問題です：

1. **集計関数の選択**: ``COUNT()`` で生徒数を数える
2. **GROUP BYの指定**: クラスごとに集計するため、クラスを識別する全カラムを指定
3. **SELECTとGROUP BYの関係**: SELECTに含める非集計カラムは、すべてGROUP BYに含める必要がある

注意点：

* ``COUNT(*)`` でも同じ結果になりますが、``COUNT(students.student_id)`` の方が意図が明確
* class_idだけでなく、gradeとclass_nameもGROUP BYに含める（PostgreSQLの仕様）

演習2：数学の優秀クラス
-----------------------

**問題**: 数学で80点以上を取った生徒が最も多いクラスを見つけてください

**解答**:

.. code-block:: sql

   SELECT 
       classes.grade AS "学年",
       classes.class_name AS "クラス",
       COUNT(students.student_id) AS "80点以上の生徒数"
   FROM scores
   INNER JOIN students ON scores.student_id = students.student_id
   INNER JOIN subjects ON scores.subject_id = subjects.subject_id
   INNER JOIN classes ON students.class_id = classes.class_id
   WHERE subjects.subject_name = '数学'
     AND scores.score >= 80
   GROUP BY classes.class_id, classes.grade, classes.class_name
   ORDER BY COUNT(students.student_id) DESC
   LIMIT 1;

**解説**:

JOINとGROUP BYを組み合わせた応用問題です：

1. **WHERE句での絞り込み**:
   
   * GROUP BY前に条件でフィルタリング
   * 数学の80点以上のデータのみを対象にする

2. **集計とソート**:
   
   * クラスごとに該当する生徒数をカウント
   * ``ORDER BY COUNT() DESC`` で多い順に並べる

3. **LIMIT句の活用**:
   
   * 最も多いクラスだけを表示するため ``LIMIT 1`` を使用

この問題を解くコツ：

* まずWHERE句で必要なデータに絞り込む
* その後でGROUP BYで集計する
* 最後に並び替えて上位を取得する

発展的な学習
============

これらの演習問題をマスターしたら、以下のような発展的な課題にも挑戦してみてください：

1. **複数条件での集計**: 各クラスの教科別平均点を70点以上の教科だけ表示
2. **サブクエリの活用**: 平均点が全体平均を上回る生徒のリスト
3. **CASE文との組み合わせ**: 点数を評価（優・良・可・不可）に変換して集計

まとめ
======

演習問題を通じて学んだポイント：

* JOINは必要な情報を持つテーブルを特定することから始める
* GROUP BYでは、SELECTの非集計カラムをすべて含める
* WHERE句（グループ化前）とHAVING句（グループ化後）の使い分け
* 実際のデータで試すことで理解が深まる

これらの基本をマスターすれば、実務でも活用できるSQLスキルが身につきます。