# 環境構築

## 必要なソフトウェア

このワークショップを始める前に、以下のソフトウェアをインストールしてください。

### 1. Docker Desktop

PostgreSQLとpgAdminをコンテナで実行するために必要です。

- **Windows/Mac**: [Docker Desktop](https://www.docker.com/products/docker-desktop)をダウンロード
- **Linux**: Docker EngineとDocker Composeをインストール

```bash
# Linuxの場合（Ubuntu/Debian）
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
```

### 2. Git（オプション）

教材リポジトリをクローンする場合に使用します。

```bash
# リポジトリのクローン
git clone https://github.com/tokibito/techramen-2025-workshop.git
cd techramen-2025-workshop
```

## Docker環境の起動

### 1. プロジェクトディレクトリへ移動

```bash
cd techramen-2025-workshop/docker
```

### 2. コンテナの起動

```bash
docker-compose up -d
```

初回起動時は、イメージのダウンロードに時間がかかる場合があります。

### 3. 起動確認

```bash
docker-compose ps
```

以下のような出力が表示されれば成功です：

```
NAME                    STATUS              PORTS
workshop_postgres       Up 10 seconds       0.0.0.0:5432->5432/tcp
workshop_pgadmin        Up 8 seconds        0.0.0.0:8080->80/tcp
```

## pgAdminへのアクセス

### 1. Webブラウザでアクセス

以下のURLにアクセスしてください：

```
http://localhost:8080
```

### 2. ログイン

以下の認証情報でログインします：

- **Email**: admin@workshop.local
- **Password**: admin123

### 3. データベース接続

pgAdminにログイン後、左側のツリーに「Workshop PostgreSQL」が表示されています。
初回接続時にパスワードを求められた場合は、以下を入力してください：

- **Password**: workshop123

## データベース接続情報

SQLクライアントやアプリケーションから接続する場合の情報：

| 項目 | 値 |
|------|-----|
| ホスト | localhost |
| ポート | 5432 |
| データベース | workshop_db |
| ユーザー | workshop |
| パスワード | workshop123 |
| スキーマ | workshop |

## 動作確認

### 1. pgAdminでクエリツールを開く

1. 「Workshop PostgreSQL」を展開
2. 「Databases」→「workshop_db」を展開
3. 右クリックして「Query Tool」を選択

### 2. テスト用クエリの実行

以下のクエリを実行して、サンプルデータが正しく設定されているか確認します：

```sql
-- スキーマの確認
SELECT current_schema();

-- テーブル一覧の確認
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'workshop'
ORDER BY table_name;

-- サンプルデータの確認
SELECT * FROM workshop.employees LIMIT 5;
```

### 3. 期待される結果

- 現在のスキーマが「workshop」と表示される
- 4つのテーブル（departments, employees, employee_projects, projects）が表示される
- 社員データが表示される

## トラブルシューティング

### コンテナが起動しない場合

```bash
# ログの確認
docker-compose logs

# コンテナの再起動
docker-compose restart

# 完全にリセットする場合
docker-compose down -v
docker-compose up -d
```

### pgAdminに接続できない場合

1. ファイアウォールの設定を確認
2. ポート8080が他のアプリケーションで使用されていないか確認
3. ブラウザのキャッシュをクリア

### PostgreSQLに接続できない場合

```bash
# PostgreSQLコンテナに直接接続してテスト
docker exec -it workshop_postgres psql -U workshop -d workshop_db
```

## 環境の停止と削除

### 一時停止（データは保持）

```bash
docker-compose stop
```

### 再開

```bash
docker-compose start
```

### 完全削除（データも削除）

```bash
docker-compose down -v
```

## 次のステップ

環境構築が完了したら、「SQL基礎編」に進んで、基本的なSQLクエリから学習を始めましょう！