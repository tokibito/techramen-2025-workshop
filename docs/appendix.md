# 付録

## データベース構造

### ER図

```
classes (学級)
├─ class_id (PK)
├─ grade (学年: 1-3)
├─ class_number (クラス番号: 1-9)
├─ class_name (クラス名: 例: "1年1組")
└─ homeroom_teacher (担任教師名)

students (生徒)
├─ student_id (PK)
├─ student_number (学籍番号)
├─ last_name (姓)
├─ first_name (名)
├─ gender (性別: M/F)
├─ birth_date (生年月日)
├─ class_id (FK → classes.class_id)
└─ enrollment_date (入学日)

subjects (教科)
├─ subject_id (PK)
├─ subject_name (教科名)
└─ subject_code (教科コード)

exams (テスト)
├─ exam_id (PK)
├─ exam_name (テスト名)
├─ exam_date (テスト日)
├─ exam_number (テスト番号: 1-5)
└─ semester (学期: 1-3)

scores (成績)
├─ score_id (PK)
├─ student_id (FK → students.student_id)
├─ subject_id (FK → subjects.subject_id)
├─ exam_id (FK → exams.exam_id)
├─ score (点数: 0-100)
└─ is_absent (欠席フラグ)
```

## SQL関数リファレンス

### 集計関数

| 関数 | 説明 | 例 |
|------|------|-----|
| COUNT(*) | 行数をカウント | `COUNT(*)` |
| COUNT(column) | NULL以外の値をカウント | `COUNT(score)` |
| COUNT(DISTINCT column) | 重複を除いてカウント | `COUNT(DISTINCT student_id)` |
| SUM(column) | 合計値 | `SUM(score)` |
| AVG(column) | 平均値 | `AVG(score)` |
| MAX(column) | 最大値 | `MAX(score)` |
| MIN(column) | 最小値 | `MIN(score)` |
| STDDEV(column) | 標準偏差 | `STDDEV(score)` |

### 文字列関数

| 関数 | 説明 | 例 |
|------|------|-----|
| \|\| | 文字列結合 | `last_name \|\| ' ' \|\| first_name` |
| LENGTH(string) | 文字列長 | `LENGTH(student_name)` |
| UPPER(string) | 大文字変換 | `UPPER(name)` |
| LOWER(string) | 小文字変換 | `LOWER(name)` |
| SUBSTRING(string, start, length) | 部分文字列 | `SUBSTRING(student_number, 1, 4)` |

### 日付関数

| 関数 | 説明 | 例 |
|------|------|-----|
| CURRENT_DATE | 現在の日付 | `CURRENT_DATE` |
| CURRENT_TIMESTAMP | 現在の日時 | `CURRENT_TIMESTAMP` |
| AGE(date) | 経過時間 | `AGE(birth_date)` |
| EXTRACT(field FROM date) | 日付の一部を抽出 | `EXTRACT(YEAR FROM birth_date)` |
| DATE_PART(field, date) | 日付の一部を取得 | `DATE_PART('month', exam_date)` |

### 条件関数

| 関数 | 説明 | 例 |
|------|------|-----|
| CASE WHEN THEN END | 条件分岐 | `CASE WHEN score >= 80 THEN '優' END` |
| COALESCE(val1, val2, ...) | 最初のNULL以外の値 | `COALESCE(score, 0)` |
| NULLIF(val1, val2) | 等しい場合NULL | `NULLIF(score, 0)` |

### ウィンドウ関数

| 関数 | 説明 | 例 |
|------|------|-----|
| ROW_NUMBER() | 行番号 | `ROW_NUMBER() OVER (ORDER BY score DESC)` |
| RANK() | ランク（同順位あり） | `RANK() OVER (ORDER BY score DESC)` |
| DENSE_RANK() | 密なランク | `DENSE_RANK() OVER (ORDER BY score DESC)` |
| LAG(column) | 前の行の値 | `LAG(score) OVER (ORDER BY exam_date)` |
| LEAD(column) | 次の行の値 | `LEAD(score) OVER (ORDER BY exam_date)` |

## よくあるエラーと対処法

### 1. GROUP BYエラー
```
ERROR: column must appear in the GROUP BY clause
```
**原因**: SELECT句に集計関数以外の列があるが、GROUP BYに含まれていない
**対処**: GROUP BYに該当列を追加する

### 2. 外部キー制約エラー
```
ERROR: violates foreign key constraint
```
**原因**: 参照先に存在しない値を挿入/更新しようとした
**対処**: 参照先のデータを確認し、正しい値を使用する

### 3. NULL値の扱い
```
ERROR: operator does not exist: integer = boolean
```
**原因**: NULL値の比較で = NULL を使用した
**対処**: IS NULL または IS NOT NULL を使用する

### 4. 型の不一致
```
ERROR: operator does not exist: text = integer
```
**原因**: 異なる型同士を比較している
**対処**: CAST関数で型変換するか、適切な型を使用する

## パフォーマンスのヒント

1. **インデックスの活用**
   - WHERE句でよく使う列にはインデックスが設定されている
   - student_id, subject_id, exam_id など

2. **不要なデータの除外**
   - WHERE句で早めに絞り込む
   - 必要な列のみSELECTする

3. **JOINの順序**
   - 小さいテーブルから大きいテーブルへJOIN
   - 絞り込み条件のあるテーブルを先に

4. **集計の効率化**
   - GROUP BYの前にWHEREで絞り込む
   - 必要に応じてインデックスを活用

## 参考リンク

- [PostgreSQL公式ドキュメント](https://www.postgresql.org/docs/)
- [pgAdmin公式サイト](https://www.pgadmin.org/)
- [SQL標準について](https://modern-sql.com/)