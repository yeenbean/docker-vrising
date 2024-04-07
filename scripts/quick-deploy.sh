#!/usr/bin/env bash
# bash <(curl -s https://raw.githubusercontent.com/yeenbean/docker-vrising/main/scripts/quick-deploy.sh)

echo " ██▒   █▓    ██▀███   ██▓  ██████  ██▓ ███▄    █   ▄████ ";
echo "▓██░   █▒   ▓██ ▒ ██▒▓██▒▒██    ▒ ▓██▒ ██ ▀█   █  ██▒ ▀█▒";
echo " ▓██  █▒░   ▓██ ░▄█ ▒▒██▒░ ▓██▄   ▒██▒▓██  ▀█ ██▒▒██░▄▄▄░";
echo "  ▒██ █░░   ▒██▀▀█▄  ░██░  ▒   ██▒░██░▓██▒  ▐▌██▒░▓█  ██▓";
echo "   ▒▀█░     ░██▓ ▒██▒░██░▒██████▒▒░██░▒██░   ▓██░░▒▓███▀▒";
echo "   ░ ▐░     ░ ▒▓ ░▒▓░░▓  ▒ ▒▓▒ ▒ ░░▓  ░ ▒░   ▒ ▒  ░▒   ▒ ";
echo "   ░ ░░       ░▒ ░ ▒░ ▒ ░░ ░▒  ░ ░ ▒ ░░ ░░   ░ ▒░  ░   ░ ";
echo "     ░░       ░░   ░  ▒ ░░  ░  ░   ▒ ░   ░   ░ ░ ░ ░   ░ ";
echo "      ░        ░      ░        ░   ░           ░       ░ ";
echo "     ░                                                   ";
echo

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo "$NAME $VERSION_ID"

if [ "$OS" == "Ubuntu" ]; then
    if [ "$VERSION_ID" == "22.04" ]; then
        echo "Operating system is supported. Proceeding with installation..."

        # Ubuntu 22.04 specific install
        ## Get prerequisites
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg git dialog

        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        ## Install docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        ## Add current user to docker group
        sudo usermod -a -G docker $USER
    else
        echo "At this time, only Ubuntu 22.04 is supported. Sorry. :("
        exit -2
    fi
else
    echo "At this time, only Ubuntu 22.04 is supported. Sorry. :("
    exit -1
fi

## Clone repository into home directory
cd ~/
git clone https://github.com/yeenbean/docker-vrising.git
cd ~/docker-vrising
mkdir saves
cp .env.example .env

echo
echo
echo "All done."
echo
echo "[WARN] You will need to log out and back in before Docker will work."
echo "Use \"vrising-lifecycle-controller.sh init\" to configure your server."
echo "Then, you can start the server with \"vrising-lifecycle-controller.sh start\""
