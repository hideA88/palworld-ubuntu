#!/bin/sh

get_free_memory_percentage() {
    # メモリおよびスワップの情報を取得
    memory_info=$(free -m)

    # "Free"列と"Swap"列の値を取得
    free_memory=$(echo "$memory_info" | awk 'NR==2{print $4}')
    free_swap=$(echo "$memory_info" | awk 'NR==3{print $4}')

    # 合計メモリと合計スワップを取得
    total_memory=$(echo "$memory_info" | awk 'NR==2{print $2}')
    total_swap=$(echo "$memory_info" | awk 'NR==3{print $2}')

    # 合計メモリと合計スワップを合算
    total_memory_with_swap=$((total_memory + total_swap))

    # "Free"メモリと"Free"スワップを合算
    total_free_memory=$((free_memory + free_swap))

    # "Free"領域の割合を計算
    free_memory_percentage=$(awk "BEGIN {printf \"%.2f\", $total_free_memory / $total_memory_with_swap * 100}")

    # "Free"領域の割合を返す
    echo "$free_memory_percentage"
}

# $0 からファイル名のみを抽出
entry_script_name=$(basename "$0")

if [ "$entry_script_name" = "check_free_memory.sh" ]; then
    free_percentage=$(get_free_memory_percentage)
    echo "Freeメモリの割合（スワップ含む）: $free_percentage%"
fi
