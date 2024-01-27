#!/bin/bash

### Discord Webhook Message
UPDATE_RESERVED_MESSAGE="@everyone 新しいバージョンが見つかったにゃ!!更新があるからサーバー再起動を5分後にするにゃ!タイトルに戻ってセーブするにゃ!!"
UPDATE_SUCCESS_MESSAGE="サーバー更新が完了したにゃ!!3時間後にまたチェックするにゃ!"
NOT_UPDATE_MESSAGE="今回は更新がなかったにゃ。3時間後にまたチェックするにゃ"
NOT_RESTART_MESSAGE="今回は再起動なしにゃ！"

FORCE_RESTART_SUCCESS_MESSAGE="サーバー再起動が完了したにゃ!!協力感謝するにゃ!"

RESTART_START_MESSAGE="@everyone 今からサーバー再起動するにゃ!!!しばらく待つにゃ!"
RESTART_FAILURE_MESSAGE="$ADMIN_GROUP_MENTION サーバー再起動に失敗したにゃ!!管理者さん助けてにゃ!!"

free_memory_message() {
    free_per=$1
    if [ "$(echo "$free_per >= 50" | bc)" -eq 1 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！余裕だにゃ!!"
    elif [ "$(echo "$free_per >= 25" | bc)" -eq 1 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！まだ焦るタイミングではないにゃ"
    elif [ "$(echo "$free_per >= 10" | bc)" -eq 1 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！そろそろやばいかもにゃ！セーブの準備しとくにゃ!"
    else
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！やばいにゃ！！今すぐ再起動したほうがいいにゃ!!"
    fi
}

restart_reserve_message() {
    wait_time=$1
    if [ $wait_time -eq 0 ]; then
        post_discord_webhook "$RESTART_START_MESSAGE"
    else
        minutes=$((wait_time / 60))
        post_discord_webhook "$RESTART_START_MESSAGE $minutes分後に再起動するにゃ!"
    fi
}

post_discord_webhook() {
    MESSAGE_CONTENT=$1
    REQUEST_BODY="{\"content\":\"$MESSAGE_CONTENT\"}"
    curl -X POST -H "Content-Type: application/json" -d "$REQUEST_BODY" "$DISCORD_WEBHOOK_URL"
}
