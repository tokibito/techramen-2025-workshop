# SQL JOIN編

この章では、複数のテーブルを結合してデータを取得する方法を学習します。JOINは、リレーショナルデータベースの最も重要な機能の一つです。

## JOINとは？

JOINは、複数のテーブルから関連するデータを組み合わせて取得するための機能です。例えば：

- 生徒の名前と所属クラス名を一緒に表示したい
- 成績データに教科名を含めて表示したい
- 各クラスの平均点を計算したい

このような場合にJOINを使用します。

## 学習内容

### 1. INNER JOIN（内部結合）
- 両方のテーブルに存在するデータのみを結合
- 最も基本的で頻繁に使用されるJOIN
- 複数テーブルの連続結合
- USING句の使い方

### 2. OUTER JOIN（外部結合）
- **LEFT JOIN**: 左側のテーブルのすべてのデータを含む
- **RIGHT JOIN**: 右側のテーブルのすべてのデータを含む
- **FULL OUTER JOIN**: 両方のテーブルのすべてのデータを含む
- NULL値の扱い方
- 存在しないデータの検出

### 3. 実践的な結合パターン
- 4つ以上のテーブルの結合
- サブクエリとの組み合わせ
- WITH句（CTE）を使った複雑な結合
- 自己結合（セルフジョイン）
- 結合条件の工夫

## よくある使用例

### 例1: 生徒情報とクラス情報の結合
```sql
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    c.class_name,
    c.grade
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id;
```

### 例2: 成績に教科名を含めて表示
```sql
SELECT 
    s.last_name || ' ' || s.first_name AS student_name,
    sub.subject_name,
    sc.score
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1;
```

## JOINの選び方

- **データが必ず存在する場合**: INNER JOIN
- **データが存在しない可能性がある場合**: LEFT JOIN
- **すべてのマスタデータを表示したい場合**: LEFT JOINまたはRIGHT JOIN
- **両方のテーブルのすべてのデータが必要な場合**: FULL OUTER JOIN

準備ができたら、実際にJOINを使ってデータを結合してみましょう！