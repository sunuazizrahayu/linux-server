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

# remove apache
cecho -c 'yellowb' "Remove default apache..."
apt purge --auto-remove apache* -y
printf "\n"

# update package list
cecho -c 'yellowb' "Updating package index..."
apt update
printf "\n"

# upgrade package
# cecho -c 'yellowb' "Try to Upgrade..."
# apt upgrade -y
# printf "\n"


# PREPARATION & REQUIREMENTS
##################################################
cecho -c 'yellowb' "Install any required packages..."
apt install \
  nano curl wget bash-completion \
  \
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
wget https://raw.githubusercontent.com/sunuazizrahayu/linux-server/main/nginx/sites.conf.d/vhost.conf.example -O /etc/nginx/sites.conf.d/vhost.conf.example
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

