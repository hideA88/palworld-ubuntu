#!/bin/bash

# for Discord Webhook settings
## 以下の変数は.envから読み込む(.env.templateをコピーして.envにリネームしてください)
# DISCORD_WEBHOOK_URL, ADMIN_GROUP_MENTION

# .env ファイルのパスを構築
script_directory=$(dirname "$(readlink -f "$0")")

# load script
. "$script_directory/load_env.sh"
. "$script_directory/check_free_memory.sh"
. "$script_directory/post_discord.sh"
. "$script_directory/restart_service.sh"
. "$script_directory/update-palworld.sh"

# 現在の時間と分を取得
current_hour=$(date +%H)
current_minute=$(date +%M)

# 3で割り切れるかつ分が5以下の場合
if [ "$((current_hour % 3))" -eq 0 ] && [ "$current_minute" -le 5 ]; then
    check_update
fi

# 関数の戻り値を取得
check_free_memory
need_restart=$?

# 関数の戻り値に応じた処理
if [ "$need_restart" -eq 1 ]; then
    restart_palworld $RESTART_WAIT_TIME
else 
    echo "not restart"
fi