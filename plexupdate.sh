#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# Forked from:
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/

# variables
plexPrefFolder="/volume1/Plex/Library/Application Support/Plex Media Server"
tmpFolder="/tmp/plex"
waitPeriod=30

# stop plex
echo `date +"%Y-%m-%d %T"` - Stopping Plex Media Server
/usr/syno/bin/synopkg stop "Plex Media Server"

# create temp folder
mkdir -p $tmpFolder/ > /dev/null 2>&1

# get available version based on architecture
token=$(cat "$plexPrefFolder"/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
jq=$(curl -s ${url})

# use sed to strip anything after the hythen
curversion=$(synopkg version "Plex Media Server" | sed -E 's/(.*)-.*/\1/')
echo `date +"%Y-%m-%d %T"` - Currrent Version: $curversion

newversion=$(echo $jq | jq -r .nas.Synology.version | sed -E 's/(.*)-.*/\1/')
echo `date +"%Y-%m-%d %T"` - New Version: $newversion

# compare version numbers
if [ "$newversion" != "$curversion" ]

# new version available
then
    # download new version
    echo `date +"%Y-%m-%d %T"` - New Version Available
    /usr/syno/bin/synonotify PKGHasUpgrade '{"[%HOSTNAME%]": $(hostname), "[%OSNAME%]": "Synology", "[%PKG_HAS_UPDATE%]": "Plex", "[%COMPANY_NAME%]": "Synology"}'
    CPU=$(uname -m)
    url=$(echo "${jq}" | jq -r '.nas.Synology.releases[] | select(.build=="linux-'"${CPU}"'") | .url')

    echo `date +"%Y-%m-%d %T"` - Downloading New Version
    /bin/wget $url -P $tmpFolder/

    # install version
    echo `date +"%Y-%m-%d %T"` - Installing New Version
    /usr/syno/bin/synopkg install $tmpFolder/*.spk

    echo `date +"%Y-%m-%d %T"` - Wait $waitPeriod seconds
    sleep $waitPeriod

    # clean up
    echo `date +"%Y-%m-%d %T"` - Removing Temp Files
    rm -rf $tmpFolder/*

# no update
else
    echo `date +"%Y-%m-%d %T"` - No New Version
fi

# restart plex
echo `date +"%Y-%m-%d %T"` - Starting Plex Media Server
/usr/syno/bin/synopkg start "Plex Media Server"

exit