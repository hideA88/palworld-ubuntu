SERVICE_NAME="palworld-dedicated.service"

### 5分間
RESTART_WAIT_TIME=300

_restart_palworld() {
        post_discord_webhook "$RESTART_START_MESSAGE"
        echo "Restart $SERVICE_NAME because an game update exists."
        systemctl stop $SERVICE_NAME
        sleep 3
        systemctl start $SERVICE_NAME

        # systemctl status コマンドでサービスのステータスを確認
        status=$(sudo systemctl status $SERVICE_NAME)

        # 結果を出力
        echo "$SERVICE_NAME status is $status"

        result=0
        # ステータスに "active" が含まれているかを確認
        if [ "$(echo "$status" | grep 'Active: active')" ]; then
                echo "サービス $SERVICE_NAME は起動しています。"
                post_discord_webhook "$FORCE_RESTART_SUCCESS_MESSAGE"
                result=0
        else
                echo "サービス $SERVICE_NAME は起動していません。"
                post_discord_webhook "$RESTART_FAILURE_MESSAGE"
                result=-1
        fi
        echo $result
}

restart_palworld() {
        wait_time=$1
        echo "Force restart option detected. $SERVICE_NAME force restart."
        restart_reserve_message $wait_time
        result=0
        if [ $wait_time -eq 0 ]; then
                echo "Wait time is 0. Restart immediately."
                result=$(_restart_palworld)
        else
                echo "Wait time is $wait_time seconds. Restart after $wait_time seconds."
                sleep $wait_time
                result=$(_restart_palworld)
        fi
        echo "$result"
}

# $0 からファイル名のみを抽出
entry_script_name=$(basename "$0")

# 直接ファイルを起動したときのみ実行
if [ "$entry_script_name" = "restart_service.sh" ]; then
        # 強制再起動オプションの確認
        if [ "$#" -gt 0 ] && [ "$1" = "--force-restart" ]; then
                result=$(restart_palworld $RESTART_WAIT_TIME)
                exit $result
        fi

        if [ "$#" -gt 0 ] && [ "$1" = "--force-restart-now" ]; then
                read -p "本当に今すぐ再起動を実行しますか？ (y/n): " user_input
                if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
                        echo "再起動を実行します。"
                        result=$(restart_palworld 0)
                        exit $result
                else
                        echo "キャンセルしました。"
                        exit 0
                fi
        fi
fi
