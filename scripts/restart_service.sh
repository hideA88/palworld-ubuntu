SERVICE_NAME="palworld-dedicated.service"

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

        # ステータスに "active" が含まれているかを確認
        if [ "$(echo "$status" | grep 'Active: active')" ]; then
                echo "サービス $SERVICE_NAME は起動しています。"
                return 0
        else
                echo "サービス $SERVICE_NAME は起動していません。"
                post_discord_webhook "$RESTART_FAILURE_MESSAGE"
                return -1
        fi
}

restart_palworld() {
        wait_time=$1
        echo "Force restart option detected. $SERVICE_NAME force restart."
        restart_reserve_message $wait_time
        if [ $wait_time -eq 0 ]; then
                echo "Wait time is 0. Restart immediately."
                _restart_palworld
        else
                echo "Wait time is $wait_time seconds. Restart after $wait_time seconds."
                sleep $wait_time
                _restart_palworld
        fi

        # ここで早期リターンする
        return_value=$?
        # 返り値に基づく条件分岐
        if [ $return_value -eq 0 ]; then
                post_discord_webhook "$FORCE_RESTART_SUCCESS_MESSAGE"
        fi
}
