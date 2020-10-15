#!/bin/bash

echo -e ""
echo -e "Scripts are placed in the right position and modified to work!"

PATH=$PATH:/usr/local/bin
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT=$CURRENT_DIR/greenlight-startup.sh
TARGET=/usr/local/bin/greenlight
CRON_LINE1="  30 1  *   *   *     /usr/local/bin/greenlight -r"
CRON_LINE2="@reboot /usr/local/bin/greenlight -s"

if [[ (-f $SCRIPT) ]];
then
	if [[ (-f $TARGET) ]];
	then
		read -p 'Greenlight startup script allready in place! Replace? (Y/n): ' CUR_ANSW

		if [[ ($CUR_ANSW = "Y") || ($CUR_ANSW = "y") || (-z $CUR_ANSW) ]];
		then
			cp -f $SCRIPT $TARGET
			chmod +x $TARGET
		elif [[ ($CUR_ANSW = "N") || ($CUR_ANSW = "n") ]];
		then
			echo -e "Skipping start up script on user input!"
		else
			echo -e "Wrong input! Aborting!" && exit 1
		fi
	else
		cp -f $SCRIPT $TARGET
                chmod +x $TARGET
	fi
fi

echo -e "Crontab is beeing edited!"

CRON_CHECK1=$(crontab -l | grep "/usr/local/bin/greenlight -r")
CRON_CHECK1_RET=$?

if [[ ($CRON_CHECK1_RET != 0) ]];
then
	(crontab -u root -l; echo "$CRON_LINE1" ) | crontab -u root -
else
	echo -e "Cronjob 1 allready in place!"
fi

CRON_CHECK2=$(crontab -l | grep "/usr/local/bin/greenlight -s")
CRON_CHECK2_RET=$?

if [[ ($CRON_CHECK2_RET != 0) ]];
then
        (crontab -u root -l; echo "$CRON_LINE2" ) | crontab -u root -
else
        echo -e "Cronjob 2 allready in place!"
fi

echo -e "Processes run sucessfully!" && echo -e "" && exit 0
