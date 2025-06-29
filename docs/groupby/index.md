# SQL GROUP BY編

この章では、データを集計・分析するためのGROUP BY句と集計関数を学習します。大量のデータから意味のある情報を抽出する重要な機能です。

## GROUP BYとは？

GROUP BYは、指定した列の値でデータをグループ化し、各グループに対して集計を行う機能です。例えば：

- クラスごとの平均点を計算
- 教科ごとの最高点・最低点を確認
- 学年別の生徒数をカウント
- テストごとの成績分布を分析

このような集計処理にGROUP BYを使用します。

## 学習内容

### 1. GROUP BYの基本
- 基本的な集計関数（COUNT、SUM、AVG、MAX、MIN）
- 単一列でのグループ化
- 複数列でのグループ化
- WHERE句とGROUP BYの組み合わせ
- HAVING句による集計結果の絞り込み
- DISTINCTとの組み合わせ

### 2. 高度なGROUP BY
- GROUPING SETS（複数の集計を一度に実行）
- ROLLUP（階層的な集計）
- CUBE（すべての組み合わせで集計）
- GROUPING関数の使い方
- ウィンドウ関数との組み合わせ
- パーセンタイル集計

### 3. 実践的な集計例
- 月次レポート形式の集計
- 前回比較分析
- トップ/ボトム分析
- 異常値検出
- 相関分析
- トレンド分析
- 成績分布のヒストグラム

## よく使う集計関数

| 関数 | 説明 | 使用例 |
|------|------|--------|
| COUNT() | 行数をカウント | `COUNT(*)` または `COUNT(score)` |
| SUM() | 合計値を計算 | `SUM(score)` |
| AVG() | 平均値を計算 | `AVG(score)` |
| MAX() | 最大値を取得 | `MAX(score)` |
| MIN() | 最小値を取得 | `MIN(score)` |
| STDDEV() | 標準偏差を計算 | `STDDEV(score)` |

## 基本的な使用例

### 例1: クラスごとの平均点
```sql
SELECT 
    c.class_name,
    AVG(sc.score) AS avg_score
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
GROUP BY c.class_name
ORDER BY avg_score DESC;
```

### 例2: 科目ごとの成績分布
```sql
SELECT 
    sub.subject_name,
    COUNT(CASE WHEN sc.score >= 80 THEN 1 END) AS excellent,
    COUNT(CASE WHEN sc.score >= 60 AND sc.score < 80 THEN 1 END) AS good,
    COUNT(CASE WHEN sc.score < 60 THEN 1 END) AS needs_improvement
FROM workshop.scores sc
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
  AND sc.score IS NOT NULL
GROUP BY sub.subject_name;
```

## 注意点

- GROUP BYに指定した列は、SELECT句でも使用できる
- 集計関数を使わない列は、必ずGROUP BYに含める必要がある
- WHERE句は集計前の絞り込み、HAVING句は集計後の絞り込み
- NULL値の扱いに注意（COUNT(*)とCOUNT(列名)の違い）

準備ができたら、実際にデータを集計してみましょう！