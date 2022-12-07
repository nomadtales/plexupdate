#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# Forked from:
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/

echo `date +"%Y-%m-%d %T"` - Stopping Plex Media Server
/usr/syno/bin/synopkg stop "Plex Media Server"

mkdir -p /tmp/plex/ > /dev/null 2>&1

token=$(cat /volume1/Plex/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
jq=$(curl -s ${url})

newversion=$(echo $jq | jq -r .nas.Synology.version)
echo `date +"%Y-%m-%d %T"` - New Version: $newversion

curversion=$(synopkg version "Plex Media Server")
echo `date +"%Y-%m-%d %T"` - Currrent Version: $curversion

if [ "$newversion" != "$curversion" ]
then
echo `date +"%Y-%m-%d %T"` - New Version Available
/usr/syno/bin/synonotify PKGHasUpgrade '{"[%HOSTNAME%]": $(hostname), "[%OSNAME%]": "Synology", "[%PKG_HAS_UPDATE%]": "Plex", "[%COMPANY_NAME%]": "Synology"}'
CPU=$(uname -m)
url=$(echo "${jq}" | jq -r '.nas.Synology.releases[] | select(.build=="linux-'"${CPU}"'") | .url')

echo `date +"%Y-%m-%d %T"` - Downloading New Version
/bin/wget $url -P /tmp/plex/

echo `date +"%Y-%m-%d %T"` - Installing New Version
/usr/syno/bin/synopkg install /tmp/plex/*.spk

sleep 30

echo `date +"%Y-%m-%d %T"` - Removing Temp Files
rm -rf /tmp/plex/*
else

echo `date +"%Y-%m-%d %T"` - No New Version
fi

echo `date +"%Y-%m-%d %T"` - Starting Plex Media Server
/usr/syno/bin/synopkg start "Plex Media Server"

exit