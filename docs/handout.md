# SQL基礎トレーニング 配布資料

## 今日使うデータベース
中学校の成績管理システム
- **生徒**: 60名（各学年2クラス、各クラス10名）
- **教科**: 5教科（国語、数学、英語、理科、社会）
- **テスト**: 5回分の成績データ

## 1. JOINの基本

### なぜJOINが必要？
別々のテーブルに分かれたデータを組み合わせて見たいとき

### 基本構文
```sql
SELECT 列名
FROM テーブル1
INNER JOIN テーブル2 ON 結合条件
```

### 実例
```sql
-- 生徒の名前とクラス名を表示
SELECT 
    s.last_name || ' ' || s.first_name AS 名前,
    c.class_name AS クラス
FROM workshop.students s
INNER JOIN workshop.classes c ON s.class_id = c.class_id;
```

## 2. GROUP BYの基本

### なぜGROUP BYが必要？
データをグループごとに集計したいとき

### 基本構文
```sql
SELECT 列名, 集計関数(列名)
FROM テーブル
GROUP BY 列名
```

### よく使う集計関数
- **COUNT()**: 件数を数える
- **AVG()**: 平均を計算
- **SUM()**: 合計を計算
- **MAX()**: 最大値
- **MIN()**: 最小値

### 実例
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

## 3. 練習問題

### 問題1
1年1組の生徒一覧を表示してください（名前とメールアドレス）

### 問題2
各科目の最高点を表示してください（1学期中間テスト）

### 問題3
80点以上を取った生徒の名前と科目、点数を表示してください

## メモ欄

---

## pgAdminアクセス情報
- URL: http://localhost:8080
- Email: admin@workshop.local
- Password: admin123