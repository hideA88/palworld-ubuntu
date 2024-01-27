#!/bin/bash

### Discord Webhook Message
UPDATE_RESERVED_MESSAGE="@everyone 新しいバージョンが見つかったにゃ!!更新があるからサーバー再起動を5分後にするにゃ!タイトルに戻ってセーブするにゃ!!"
UPDATE_SUCCESS_MESSAGE="サーバー更新が完了したにゃ!!3時間後にまたチェックするにゃ!"
NOT_UPDATE_MESSAGE="今回は更新がなかったにゃ。3時間後にまたチェックするにゃ"
NOT_RESTART_MESSAGE="今回は再起動なしにゃ！"

FORCE_RESTART_SUCCESS_MESSAGE="サーバー再起動が完了したにゃ!!協力感謝するにゃ!"

RESTART_START_MESSAGE="@everyone 今からサーバー再起動するにゃ!!!しばらく待つにゃ!"
RESTART_FAILURE_MESSAGE="$ADMIN_GROUP_MENTION サーバー再起動に失敗したにゃ!!管理者さん助けてにゃ!!"

### メモリ残量のログファイル
MEM_LOG_PATH="./memory_usage.log"

###境界の定義

threshold_90=90
threshold_50=50
threshold_25=25
threshold_10=10

check_threshold() {
    value=$1
    threshold=$2
    result=$(echo "$value > $threshold" | bc -l)
    echo "$result"
}

get_previous_memory() {
    if [ -f "$MEM_LOG_PATH" ]; then
        . "$MEM_LOG_PATH"
    else
        previous_memory=100
    fi
    echo "$previous_memory"
}

free_memory_message() {
    free_per=$1
    prev_free_per=$(get_previous_memory)

    if [ "$(check_threshold "$prev_free_per" "$threshold_90")" -eq 1 ] && [ "$(check_threshold "$free_per" "$threshold_90")" -eq 0 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！余裕だにゃ!!"
    fi

    if [ "$(check_threshold "$prev_free_per" "$threshold_50")" -eq 1 ] && [ "$(check_threshold "$free_per" "$threshold_50")" -eq 0 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！まだ焦るタイミングではないにゃ"
    fi

    if [ "$(check_threshold "$prev_free_per" "$threshold_25")" -eq 1 ] && [ "$(check_threshold "$free_per" "$threshold_25")" -eq 0 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！そろそろやばいかもにゃ！セーブの準備しとくにゃ!"
    fi

    if [ "$(check_threshold "$prev_free_per" "$threshold_10")" -eq 1 ] && [ "$(check_threshold "$free_per" "$threshold_10")" -eq 0 ]; then
        post_discord_webhook "現在のメモリ空き容量は$free_per%にゃ！！やばいにゃ！！今すぐ再起動したほうがいいにゃ!!"
    fi

    echo "previous_memory=$free_per" >"$MEM_LOG_PATH"
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
