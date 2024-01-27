#!/bin/sh

#!/bin/sh

# for Discord Webhook settings
## 以下の変数は.envから読み込む(.env.templateをコピーして.envにリネームしてください)
# DISCORD_WEBHOOK_URL, ADMIN_GROUP_MENTION

# .env ファイルのパスを構築
script_directory=$(dirname "$(readlink -f "$0")")

# load script
. "$script_directory/load_env.sh"
. "$script_directory/post_discord.sh"
. "$script_directory/check_free_memory.sh"
. "$script_directory/restart_service.sh"
. "$script_directory/update-palworld.sh"




# TODO: implement updateチェックタイミングとメモリチェックを時間帯によって分けるようにする
check_update
