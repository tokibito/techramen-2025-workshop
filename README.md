# SQL基礎トレーニング～JOIN、GROUP BYの使い方を学ぼう

TechRAMEN 2025カンファレンスで行われるSQLワークショップ（40分）の教材リポジトリです。

## 概要

このワークショップでは、SQLの中でも特に重要なJOIN操作とGROUP BY句に焦点を当てて学習します。中学校の成績管理システムのデータを題材に、SQLクエリの書き方を身につけます。

### 対象者

- SQLでSELECT文を使ったことがある方(WHERE句やORDER BY句もやったことがあれば尚良し)
- JOINやGROUP BYの使い方を理解したい方

### 学習内容（40分）

1. **導入（5分）**
   - 今回使う環境の説明

2. **JOIN編（15分）**
   - なぜJOINが必要か
   - INNER JOINの基本
   - 複数テーブルの結合

3. **GROUP BY編（15分）**
   - 集計の基本
   - 実用的な集計例
   - クラス別成績表の作成

4. **質疑応答（5分）**

## 環境構築

### ホスティングされた環境を使う場合

- Webブラウザで当日共有されたURLにアクセスしてください。

### ローカル環境でのセットアップ

- 必要なソフトウェア
   - Docker Desktop（Windows/Mac）またはDocker Engine + Docker Compose（Linux）
   - Webブラウザ

1. リポジトリのクローンまたはダウンロード
```bash
git clone https://github.com/tokibito/techramen-2025-workshop.git
cd techramen-2025-workshop
```

2. Docker環境の起動
```bash
cd docker
docker-compose up -d
```

3. pgAdminへのアクセス
- URL: http://localhost:8080
- Email: admin@workshop.local
- Password: admin123

## サンプルデータについて

中学校の成績管理システムを模したデータを使用します：
- **学級**: 1〜3年生、各学年2クラス
- **生徒**: 各クラス10名、計60名
- **教科**: 国語、数学、英語、理科、社会
- **テスト**: 年間5回分の成績データ

## ディレクトリ構成

```
.
├── docker/          # Docker Compose設定
│   ├── compose.yml
│   └── init.sql    # 初期データ
├── sql/            # SQLサンプルファイル
│   ├── basics/     # 基礎編
│   ├── joins/      # JOIN編
│   └── groupby/    # GROUP BY編
├── docs/           # ワークショップドキュメント
│   └── index.rst   # 目次
└── solutions/      # 演習問題の解答
```

## トラブルシューティング

### docker composeコマンドが見つからない場合
- Dockerが正しくインストールされているか確認してください。
- docker-composeがインストールされているか確認してください。
   - `docker-compose` コマンドがあるなら、そちらで実行してください。

### Dockerコンテナが起動しない場合
```bash
docker compose down -v
docker compose up -d
```

### pgAdminに接続できない場合
- ポート8080が他のアプリケーションで使用されていないか確認
- ブラウザのキャッシュをクリア

## 講師情報

**tokibito**
- Pythonエンジニア

## ドキュメントのビルド

ドキュメントはSphinxを使用してビルドできます。

1. venvを作成
```bash
python3 -m venv venv
source venv/bin/activate  # Windowsの場合は venv\Scripts\activate
```

2. 必要なパッケージのインストール
```bash
pip install -r docs/requirements.txt
```

3. ドキュメントのビルド
```bash
make html
```

ビルド結果は `docs/_build/html/` に出力されます。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
