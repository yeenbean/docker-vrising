#!/usr/bin/env bash

# This script facilitates the creation, management, and removal of the V Rising
# server. This includes the following features:
#
# - Wizard-based configuration of .env variables.
# - Deployment of server.
# - Server upgrades.
# - Deployment of cron schedule.
# - Manual server resets.
#
# This script optionally accepts arguments. Please use --help for usage information.

# Define usage information
usage=`cat <<EOF
Usage: vrising-lifecycle-controller.sh [OPTION]
Controls the operation of the V Rising server.

  init     Guided wizard which assists in generating the .env file.
  start    Starts the Docker container.
  stop     Stops the Docker container.
  restart  Stops then starts the Docker container.
  update   Stops the Docker container, rebuilds the image, then starts the
           new Docker container.
  reset    Stops the Docker container, removes all saves, rebuilds the image,
           then starts the Docker container.
EOF`

# variables for dialog
aspect=24
backtitle="yeenbean/vrising-docker"
title="V Rising Lifecycle Controller"

# server functions

start_server () {
    docker compose down
    docker compose up -d
}

stop_server () {
    docker compose down
}

rebuild_container () {
    docker compose down
    docker compose rm
    docker compose up -d
}

reset_world () {
    if [ "$1" == "interactively" ]; then
        yesno "Resetting the world will erase your server's saves. You may want to back up your saves before continuing. Are you sure you want to do this?"
        response=$?

        case $response in
            0)
                reset_world
                ;;
        esac
    else
        docker compose down
        rm -rf saves/Saves/
        docker compose rm
        docker compose up -d
    elif
}

# info dialog
info() {
    dialog --aspect $aspect --backtitle "$backtitle" --title $title --msgbox "$1" 0 0
    clear
}

# choice dialog
yesno() {
    dialog --aspect $aspect --backtitle "$backtitle" --title $title --yesno "$1" 0 0
    response=$?
    clear
    return $response
}

function vrisinginteractive() {
    while true; do
        # main menu
        choice=$(dialog --aspect $aspect --backtitle "$backtitle" --title "$title" \
            --menu "Choose an option:" 0 0 0 \
            "1" "Start/Restart Server" \
            "2" "Update/Rebuild Container" \
            "3" "Reset World" \
            "4" "Stop Server" \
            "5" "Quit" \
            2>&1 >/dev/tty)
        
        # menu operation
        case $choice in
            1)
                start_server
                ;;
            2)
                rebuild_container
                ;;
            3)
                reset_world interactively
                ;;
            4)
                stop_server
                ;;
            5)
                clear
                exit 0
                ;;
            *)
                info "$choice is not implemented yet."
                ;;
        esac
    done
}

# Parse input
case "$1" in
    "start")
        docker compose up -d
        ;;
    
    "stop")
        docker compose down
        ;;

    "restart")
        docker compose down
        docker compose up -d
        ;;
    
    "update")
        docker compose down
        docker compose rm
        docker compose up -d
        ;;
    
    "reset")
        docker compose down
        rm -rf ./saves/Saves/
        docker compose rm
        docker compose up -d
        ;;
    
    "")
        vrisinginteractive
        ;;
    
    *)
        echo "$usage"
esac
