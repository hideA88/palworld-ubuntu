SERVICE_NAME="palworld-dedicated.service"

restart_palworld() {
        post_discord_webhook "$RESTART_START_MESSAGE"
        echo "Restart $SERVICE_NAME because an game update exists."
        sudo systemctl stop $SERVICE_NAME
        sleep 3
        sudo systemctl start $SERVICE_NAME

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

force_restart() {
        wait_time=$1

        echo "Force restart option detected. $SERVICE_NAME force restart."
        post_discord_webhook "$FORCE_RESTART_RESERVED_MESSAGE"

        sleep $wait_time

        restart_palworld
        # ここで早期リターンする
        return_value=$?
        # 返り値に基づく条件分岐
        if [ $return_value -eq 0 ]; then
                post_discord_webhook "$FORCE_RESTART_SUCCESS_MESSAGE"
        fi
}