#!/bin/bash


mkdir -p files/etc/wireless

kr_URL="https://raw.githubusercontent.com/shiyu1314/openwrt-MI-R3G/main/switch_channel.sh"

wget -qO- $kr_URL > files/etc/wireless/switch_channel.sh

chmod +x files/etc/wireless/switch_channel.sh

echo "# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

/etc/wireless/switch_channel.sh "apclii0" &
exit 0">files/etc/rc.local

touch files/etc/wireless/apclii0
