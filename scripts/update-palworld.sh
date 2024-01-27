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

### 5分間
RESTART_WAIT_TIME=300

# Steam CMD path
Steamcmd="/usr/games/steamcmd"
install_dir="/home/steam/Steam/steamapps/common/PalServer"

check_update() {
        echo "# Check the environment."
        date
        OLD_Build=$($Steamcmd +force_install_dir $install_dir +login anonymous +app_status 2394010 +quit | grep -e "BuildID" | awk '{print $8}')
        echo "Old BuildID: $OLD_Build"

        echo "# Start updating the game server..."
        $Steamcmd +force_install_dir $install_dir +login anonymous +app_update 2394010 validate +quit >/dev/null

        echo "# Check the environment after the update."
        NEW_Build=$($Steamcmd +force_install_dir $install_dir +login anonymous +app_status 2394010 +quit | grep -e "BuildID" | awk '{print $8}')
        echo "New BuildID: $NEW_Build"
        # Check if updated.
        if [ $OLD_Build = $NEW_Build ]; then
                echo "Build number matches."
                free_per=get_free_memory_percentage
                free_memory_message $free_per
                if [ $(echo "$free_memory_percentage <= 10" | bc -l) -eq 1 ]; then
                        echo "Freeメモリの割合が10%以下です。"
                        force_restart $RESTART_WAIT_TIME
                else
                        echo "Freeメモリの割合は10%を超えています。"
                        post_discord_webhook "$NOT_RESTART_MESSAGE"
                fi
        else
                post_discord_webhook "$UPDATE_RESERVED_MESSAGE"
                sleep $RESTART_WAIT_TIME

                restart_palworld
                return_value=$?
                # 返り値に基づく条件分岐
                if [ $return_value -eq 0 ]; then
                        post_discord_webhook "$UPDATE_SUCCESS_MESSAGE"
                fi
        fi
}

### 以下メイン処理 ###

# 強制再起動オプションの確認
if [ "$#" -gt 0 ] && [ "$1" = "--force-restart" ]; then
        force_restart $RESTART_WAIT_TIME
        return_value=$?
        exit $return_value
fi

if [ "$#" -gt 0 ] && [ "$1" = "--force-restart-now" ]; then
        read -p "本当に今すぐ再起動を実行しますか？ (y/n): " user_input
        if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
                echo "再起動を実行します。"
                force_restart 1
                return_value=$?
                exit $return_value
        else
                echo "キャンセルしました。"
                exit 0
        fi
fi

# check update
check_update
