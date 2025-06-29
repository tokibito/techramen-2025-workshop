# SQL基礎編

この章では、SQLの基本的な構文と使い方を学習します。中学校の成績管理システムを題材に、実践的なクエリの書き方を身につけていきましょう。

## 学習内容

### 1. SELECT文の基本
- データの取得方法
- 列の選択と別名（エイリアス）
- 文字列の結合
- DISTINCT（重複の除外）
- 計算列の作成
- CASE式による条件分岐

### 2. WHERE句による絞り込み
- 基本的な比較演算子
- 複数条件の組み合わせ（AND/OR）
- IN/NOT IN演算子
- BETWEEN演算子
- LIKE演算子によるパターンマッチング
- NULL値の扱い
- EXISTS演算子

### 3. ORDER BY句による並び替え
- 昇順・降順ソート
- 複数列でのソート
- NULL値の扱い（NULLS FIRST/LAST）
- CASE式を使ったカスタムソート
- LIMIT/OFFSETによるページング

### 4. データの追加・更新・削除
- INSERT文によるデータ追加
- UPDATE文によるデータ更新
- DELETE文によるデータ削除
- トランザクションの基本
- 外部キー制約の考慮

## サンプルデータについて

このワークショップでは、以下のようなデータを使用します：

- **学級（classes）**: 1〜3年生、各学年2クラス
- **生徒（students）**: 各クラス10名、計60名
- **教科（subjects）**: 国語、数学、英語、理科、社会の5教科
- **テスト（exams）**: 年間5回のテスト
- **成績（scores）**: 各生徒の各教科・各テストの点数（100点満点）

## 準備

まず、pgAdminでQuery Toolを開いて、以下のクエリを実行してデータベースの構造を確認しましょう：

```sql
-- 現在のスキーマを確認
SELECT current_schema();

-- テーブル一覧を確認
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'workshop'
ORDER BY table_name;
```

準備ができたら、次のページから実際にSQLクエリを書いていきましょう！