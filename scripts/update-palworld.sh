#!/bin/sh

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
                        restart_palworld $RESTART_WAIT_TIME
                else
                        echo "Freeメモリの割合は10%を超えています。"
                        post_discord_webhook "$NOT_RESTART_MESSAGE"
                fi
        else
                post_discord_webhook "$UPDATE_RESERVED_MESSAGE"

                restart_palworld $RESTART_WAIT_TIME
                return_value=$?
                # 返り値に基づく条件分岐
                if [ $return_value -eq 0 ]; then
                        post_discord_webhook "$UPDATE_SUCCESS_MESSAGE"
                fi
        fi
}
