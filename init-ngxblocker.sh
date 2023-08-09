#!/usr/bin/env sh

set -eu

trap cleanup INT TERM EXIT

NGXBLOCKER_INSTALL_SCRIPT="/usr/local/sbin/install-ngxblocker"
NGXBLOCKER_SETUP_SCRIPT="/usr/local/sbin/setup-ngxblocker"
NGXBLOCKER_UPDATE_SCRIPT="/usr/local/sbin/update-ngxblocker"

cleanup() {
    trap - INT TERM EXIT

    rm -f "$NGXBLOCKER_INSTALL_SCRIPT"
    rm -f "$NGXBLOCKER_SETUP_SCRIPT"
}

mkdir -p /usr/local/sbin

curl -sSf --tlsv1.2 --proto '=https' -L \
    "https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker" \
    -o "$NGXBLOCKER_INSTALL_SCRIPT"

chmod +x "$NGXBLOCKER_INSTALL_SCRIPT"

"$NGXBLOCKER_INSTALL_SCRIPT" -x

chmod +x "$NGXBLOCKER_SETUP_SCRIPT"
chmod +x "$NGXBLOCKER_UPDATE_SCRIPT"

"$NGXBLOCKER_SETUP_SCRIPT" -x

# check syntax of NGINX configurations
nginx -t

# add scheduled update
(
    crontab -l
    echo "00 22 * * * $NGXBLOCKER_UPDATE_SCRIPT -n"
) | sort - | uniq - | crontab -
