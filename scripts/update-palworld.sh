#!/bin/bash

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
                post_discord_webhook "$NOT_UPDATE_MESSAGE"
        else
                echo "find update. $NEW_Build > $OLD_Build"
                post_discord_webhook "$UPDATE_RESERVED_MESSAGE"
                result=$(restart_palworld $RESTART_WAIT_TIME)
                # 返り値に基づく条件分岐
                if [ $result -eq 0 ]; then
                        post_discord_webhook "$UPDATE_SUCCESS_MESSAGE"
                fi
        fi
}
