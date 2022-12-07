# Description
Automatically update Plex Media Server on Synology NAS

# How to
Download the script and put it into a Scheduled Task

## Setup Download Script
1. SSH into your Synology
2. `sudo mkdir /volume1/Scripts`
3. `sudo wget https://raw.githubusercontent.com/nomadtales/plexupdate/master/plexupdate.sh`
4. `sudo chmod +x plexupdate.sh`

## Setup Update Scheduler
1. Go back to Synology Console
2. Open Control Panel
3. Open Task Scheduler
4. Click **Create** 
5. Click **Scheduled Task** 
6. Click **User-defined script**
7. Enter Task as *Update Plex*
8. Click **Schedule** tab
9. Change Schedule to fit needs
10. Click **Task Settings** tab
11. Enter User-defined script as `bash /volume1/Scripts/plexupdate.sh > /volume1/Scripts/plexupdate.log`
12. Click **OK**