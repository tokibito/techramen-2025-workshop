# ワークショップ進行ガイド（40分）

## タイムスケジュール

### 導入（3分）
- 自己紹介とワークショップの目的
- データベースの説明（中学校の成績管理システム）

### 第1部：JOIN編（15分）

#### 1. なぜJOINが必要か（3分）
生徒の名前とクラス名を一緒に見たい！
```sql
-- まずは生徒テーブルだけ見てみる
SELECT * FROM workshop.students LIMIT 3;
-- class_idしかない...クラス名がわからない！
```

#### 2. INNER JOINで解決（5分）
```sql
-- 生徒とクラスを結合
SELECT 
    s.last_name || ' ' || s.first_name AS 名前,
    c.class_name AS クラス
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id
LIMIT 10;
```

#### 3. 3つのテーブルを結合（7分）
```sql
-- 成績に生徒名と科目名を追加
SELECT 
    s.last_name || ' ' || s.first_name AS 生徒名,
    sub.subject_name AS 科目,
    sc.score AS 点数
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1  -- 1学期中間テスト
LIMIT 20;
```

### 第2部：GROUP BY編（15分）

#### 1. 集計の基本（5分）
```sql
-- クラスごとの平均点
SELECT 
    c.class_name AS クラス,
    AVG(sc.score) AS 平均点
FROM workshop.scores sc
INNER JOIN workshop.students s ON sc.student_id = s.student_id
INNER JOIN workshop.classes c ON s.class_id = c.class_id
WHERE sc.exam_id = 1
GROUP BY c.class_name;
```

#### 2. 実用例：成績の分布（5分）
```sql
-- 80点以上は何人？
SELECT 
    sub.subject_name AS 科目,
    COUNT(CASE WHEN sc.score >= 80 THEN 1 END) AS "80点以上",
    COUNT(CASE WHEN sc.score < 80 THEN 1 END) AS "80点未満"
FROM workshop.scores sc
INNER JOIN workshop.subjects sub ON sc.subject_id = sub.subject_id
WHERE sc.exam_id = 1
GROUP BY sub.subject_name;
```

#### 3. 応用：クラス別成績表（5分）
```sql
-- 見やすい成績表を作る
SELECT 
    c.class_name AS クラス,
    COUNT(s.student_id) AS 人数,
    ROUND(AVG(sc.score), 1) AS 平均点,
    MAX(sc.score) AS 最高点
FROM workshop.classes c
INNER JOIN workshop.students s ON c.class_id = s.class_id
INNER JOIN workshop.scores sc ON s.student_id = sc.student_id
WHERE sc.exam_id = 1
GROUP BY c.class_name
ORDER BY 平均点 DESC;
```

### まとめと質疑応答（7分）
- JOINのポイント
- GROUP BYのポイント
- 質問タイム

## 配布用クイックリファレンス

### JOINの種類
- **INNER JOIN**: 両方のテーブルにあるデータのみ
- **LEFT JOIN**: 左のテーブルのすべて＋右の一致データ
- **RIGHT JOIN**: 右のテーブルのすべて＋左の一致データ

### 主要な集計関数
- **COUNT()**: 件数
- **SUM()**: 合計
- **AVG()**: 平均
- **MAX()**: 最大値
- **MIN()**: 最小値

### よく使うパターン
```sql
-- パターン1: 基本的なJOIN
FROM table1 t1
INNER JOIN table2 t2 ON t1.id = t2.id

-- パターン2: GROUP BYの基本
SELECT column1, COUNT(*), AVG(column2)
FROM table
GROUP BY column1

-- パターン3: 条件付き集計
COUNT(CASE WHEN condition THEN 1 END)
```

## 準備チェックリスト

- [ ] pgAdminにアクセスできることを確認
- [ ] サンプルクエリが実行できることを確認
- [ ] 参加者の環境確認（開始前）
- [ ] 時間配分の確認

## トラブルシューティング

### pgAdminに接続できない場合
- ブラウザのキャッシュクリア
- Docker環境の再起動
- ポート8080の確認

### クエリエラーの場合
- スキーマ名（workshop）の確認
- テーブル名のスペルチェック
- セミコロンの確認