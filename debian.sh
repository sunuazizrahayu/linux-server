#!/bin/bash

# The following function prints a text using custom color
# -c or --color define the color for the print. See the array colors for the available options.
# -n or --noline directs the system not to print a new line after the content.
# Last argument is the message to be printed.
cecho ()
{
    declare -A colors;
    colors=(\
        ['black']='\E[0;47m'\
        ['red']='\E[0;31m'\
        ['redb']='\E[1;31m'\
        ['green']='\E[0;32m'\
        ['yellow']='\E[0;33m'\
        ['yellowb']='\E[1;33m'\
        ['blue']='\E[0;34m'\
        ['magenta']='\E[0;35m'\
        ['cyan']='\E[0;36m'\
        ['white']='\E[0;37m'\
    );

    local defaultMSG="No message passed.";
    local defaultColor="black";
    local defaultNewLine=true;

    while [[ $# -gt 1 ]];
    do
    key="$1";

    case $key in
        -c|--color)
            color="$2";
            shift;
        ;;
        -n|--noline)
            newLine=false;
        ;;
        *)
            # unknown option
        ;;
    esac
    shift;
    done

    message=${1:-$defaultMSG};   # Defaults to default message.
    color=${color:-$defaultColor};   # Defaults to default color, if not specified.
    newLine=${newLine:-$defaultNewLine};

    echo -en "${colors[$color]}";
    echo -en "$message";
    if [ "$newLine" = true ] ; then
        echo;
    fi
    tput sgr0; #  Reset text attributes to normal without clearing screen.

    return;
}


## check for sudo/root
cecho -c 'yellowb' "Check root access..."
if ! [ $(id -u) = 0 ]; then
  echo "This script must run with sudo, try again..."
  exit 1
fi
printf "\n"


# update package list
cecho -c 'yellowb' "Updating package index..."
apt update
printf "\n"

# upgrade package
cecho -c 'yellowb' "Try to Upgrade..."
apt upgrade -y
printf "\n"

# remove apache
cecho -c 'yellowb' "Remove default apache..."
apt purge --auto-remove apache* -y
printf "\n"


# PREPARATION & REQUIREMENTS
##################################################
cecho -c 'yellowb' "Install any required packages..."
apt install \
  nano curl wget bash-completion lsb-release \
  ca-certificates gnupg \
  htop -y
printf "\n"


# INSTALL NGINX
##################################################
cecho -c 'yellowb' "Install NGINX web server..."
# Install
cecho -c 'green' "Install nginx"
apt install nginx -y

cecho -c 'green' "update public html"
mkdir -p /var/www/html/
rm /var/www/html/*
wget https://raw.githubusercontent.com/sunuazizrahayu/linux-server/main/nginx/www/index.html -O /var/www/html/index.html

cecho -c 'green' "create new config dir"
mkdir -p /etc/nginx/sites.conf.d/
cecho -c 'green' "set default server config on new dir"
wget https://raw.githubusercontent.com/sunuazizrahayu/linux-server/main/nginx/sites.conf.d/default.conf -O /etc/nginx/sites.conf.d/default.conf
cecho -c 'green' "set nginx config with new server config dir"
wget https://raw.githubusercontent.com/sunuazizrahayu/linux-server/main/nginx/nginx.conf -O /etc/nginx/nginx.conf

cecho -c 'green' "remove default config dir"
rm -rf /etc/nginx/conf.d/
rm -rf /etc/nginx/sites-available/
rm -rf /etc/nginx/sites-enabled/

cecho -c 'green' "reload config nginx"
nginx -t
nginx -s reload
printf "\n"


# INSTALL DOCKER: https://docs.docker.com/engine/install/debian/
##################################################
cecho -c 'yellowb' "Install Docker..."
# remove old version
cecho -c 'green' "Remove old Docker..."
apt remove docker docker-engine docker.io containerd runc -y

# Add Docker’s official GPG key:
cecho -c 'green' "Add Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Setup Docker Repo
cecho -c 'green' "Setup Docker Repository..."
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install
cecho -c 'green' "Update docker package..."
apt update
cecho -c 'green' "Installing Docker..."
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin -y

# Autorun docker
cecho -c 'green' "Set autorun Docker..."
systemctl start docker
systemctl enable docker
cecho -c 'yellowb' "Install Docker done."
printf "\n"

# Install Speedtest
cecho -c 'yellowb' "Install Speedtest..."
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
apt install speedtest -y

# Generate SSL
cecho -c 'yellowb' "Generate SSL with cloudflare..."
wget https://raw.githubusercontent.com/sunuazizrahayu/linux-server/main/ssl_cloudflare.sh -O ssl.sh
bash ssl.sh
