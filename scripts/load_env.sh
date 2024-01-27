#!/bin/sh

# スクリプトが配置されているディレクトリを取得
script_directory=$(dirname "$(readlink -f "$0")")

# .env ファイルのパスを構築
env_file="$script_directory/../.env"

# .env ファイルが存在するか確認
if [ -f "$env_file" ]; then
  # .env ファイルを読み込んで環境変数に設定
  export $(grep -v '^#' "$env_file" | xargs)
  echo ".env ファイルの内容を読み込みました。"
else
  echo ".env ファイルが存在しません。"
fi