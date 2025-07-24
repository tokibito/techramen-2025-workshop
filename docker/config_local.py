# pgAdmin local configuration file
# This file contains custom settings for pgAdmin

# サーバーモードを有効化
SERVER_MODE = True

# デフォルト言語を日本語に設定
DEFAULT_LANGUAGE = 'ja'

# マスターパスワードを不要にする
MASTER_PASSWORD_REQUIRED = False

# セッションクッキーの設定
SESSION_COOKIE_HTTPONLY = True
PERMANENT_SESSION_LIFETIME = 86400

# パスワード保存を有効化
ALLOW_SAVE_PASSWORD = True

# SQLite設定（パスワード保存用）
SQLITE_PATH = '/var/lib/pgadmin/pgadmin4.db'