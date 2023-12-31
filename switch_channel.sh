#!/bin/sh
# Switch Channel Scprit
# 2.4ghz client check

apcli="$1"
#echo "Debug:$apcli begin"
if [ "$apcli" = "apcli0" ]; then
    #echo "Debug:if ra0"
    ra="ra0"
    path='/etc/wireless/mt7615/mt7615.1.dat'
else
    #echo "Debug:if rai0"
    ra="rai0"
    path='/etc/wireless/mt7615/mt7615.2.dat'
fi
state="$(cat /etc/wireless/$apcli)"
#echo "Debug:state $state"
if [ "$state" != "" ]; then
    #echo "Debug:inside state $state"
    ifconfig $apcli up
fi
sleep 60
#echo "Debug:begin while function"
while true; do
    #echo "Debug:in the while function"
    ifconfig | grep -m 1 "$apcli" > /etc/wireless/$apcli
    up_down="$(ifconfig | grep -m 1 "$apcli")"
    #echo "Debug:begin if function, up_down $up_down"
    if [ "$up_down" != "" ]; then
        sta_enable="$(cat "$path" | grep -m 1 "ApCliEnable" | awk -F '=' '{print $2}')"
        #echo "Debug:begin if function, sta_enable $sta_enable"
        if [ "$sta_enable" = "1" ]; then    
            connect="$(iwconfig $apcli | awk -F'"' '/ESSID/ {print $2}')"
            #echo "Debug:begin if function, connect $connect"
            if [ "$connect" = "" ] ; then
                ssid="$(cat "$path" | grep -m 1 "ApCliSsid" | awk -F '=' '{print $2}')"
                #echo "Debug:begin if function, ssid $ssid"
                if [ "$ssid" != "" ] ; then
                    bssid="$(cat "$path" | grep -m 1 "ApCliBssid" | awk -F '=' '{print $2}' | tr 'A-Z' 'a-z')"
                    iwpriv $ra set SiteSurvey=1
                    sleep 1
                    channel=""
                    #echo "Debug:begin if function, bssid $bssid"
                    if [ "$bssid" = "" ] ; then 
                        #echo "Debug:begin if function, bssid $bssid, then"
                        if [ "$apcli" = "apcli0" ]; then
                            #echo "Debug:begin if channel 1"
                            channel="$(iwpriv $ra get_site_survey | grep -m 1 "$ssid " | awk '{print $1}')"
                        else
                            #echo "Debug:begin if channel 2"
                            channel="$(iwpriv $ra get_site_survey | grep -m 1 "$ssid " | awk '{print $2}')"
                        fi
                        
                    else
                        #echo "Debug:begin if function, bssid $bssid, else"
                        if [ "$apcli" = "apcli0" ]; then
                            #echo "Debug:begin if channel 3"
                            channel="$(iwpriv $ra get_site_survey | grep -m 1 "$bssid" | awk '{print $1}')"
                        else
                            #echo "Debug:begin if channel 4"
                            channel="$(iwpriv $ra get_site_survey | grep -m 1 "$bssid" | awk '{print $2}')"
                        fi
                    fi
                    #echo "Debug:begin check if channel is empty; $channel"
                    if [ "$channel" != "" ] ; then
                        #echo "Debug:inside check channel; set channel"
                        sed -i "s/^Channel=.*/Channel="$channel"/" $path
                        iwpriv $apcli set ApCliEnable=0
                        iwpriv $ra set Channel="$channel"
                        iwpriv $apcli set ApCliEnable=1
                        sleep 40
                    fi
                fi
            fi
        fi
    fi
    sleep 20
done
