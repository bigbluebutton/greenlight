#!/bin/bash

#Include NRPE-PreBuild
. /usr/lib/nagios/plugins/utils.sh

#VAR Definitiions
RoR_PIDfile=/root/greenlight/tmp/pids/server.pid

#Read User Flags
while getopts "sHS:rh" option
do
case $option in
    s)
    START_VAR="true"
#    shift # past argument=value
    ;;

    H)
    HOLD_VAR="true"
#    shift # past argument=value
    ;;

    S)
    STATUS_VAR="true"
    if [ -z $OPTARG ];
    then
        STATUS_TYPE="full"
    else
        STATUS_TYPE=$OPTARG
    fi
#    shift # past argument=value
    ;;

    r)
    RESTART_VAR="true"
#    shift # past argument=value
    ;;

    h )
    HELP_VAR="true"
        echo -e ""
        echo -e "The following flags can be used:"
        echo -e "\t-s (--start): Starts the Service if necessary"
        echo -e "\t-H (--hold): Stops the Service if necessary"
        echo -e "\t-r (--restart): Restarts the Service"
        echo -e "\t-S (--status): Shows the Status of Greenlight and related services"
        echo -e ""
        echo -e "\t\tSupported Arguments for Status:"
        echo -e "\t\t\e[1mfull\e[0m:\t\tShows full colorized output and data"
        echo -e "\t\t\e[1mport\e[0m:\t\tShows status of greenlight port only"
        echo -e "\t\t\e[1mn\e[0m:\t\tShows output in nagios standard format"
        echo -e ""

        echo -e "\t-h (--help): Shows this help page"
	echo -e ""
	echo -e ""
	echo -e "\tSyntax example:\t\t\e[1mgreenlight -S full\e[0m"
        echo -e ""
        exit $STATE_OKAY
#    shift # past argument=value
    ;;

    *)
    echo "The Flag you are trying to use is not supported!"
    exit $STATE_CRITICAL
    # unknown option
    ;;
esac
done

#UserVar Completion Check
if [[ (-z $RESTART_VAR ) && (-z $HELP_VAR) && (-z $STATUS_VAR) && (-z $START_VAR) && (-z $HOLD_VAR) ]];
then
	echo "No option flag was supplied - EXITING!"
	echo "See -h for help and syntax"
	exit $STATE_CRITICAL
fi

#UserVar sanity check
if [[ ($START_VAR="true") && (-z ${HOLD_VAR+x}) && (-z ${STATUS_VAR+x}) && (-z ${RESTART_VAR+x}) ]];
then
        HOLD_VAR="false"
        STATUS_VAR="false"
        RESTART_VAR="false"
elif [[ ($HOLD_VAR="true") && (-z ${START_VAR+x}) && (-z ${STATUS_VAR+x}) && (-z ${RESTART_VAR+x}) ]];
then
        START_VAR="false"
        STATUS_VAR="false"
        RESTART_VAR="false"
elif [[ ($STATUS_VAR = "true") && (-z ${START_VAR+x}) && (-z ${HOLD_VAR+x}) && (-z ${RESTART_VAR+x}) ]];
then
        START_VAR="false"
        HOLD_VAR="false"
        RESTART_VAR="false"
elif [[ ($RESTART_VAR = "true") && (-z ${START_VAR+x}) && (-z ${HOLD_VAR+x}) && (-z ${STATUS_VAR+x}) ]];
then
        START_VAR="false"
        HOLD_VAR="false"
        STATUS_VAR="false"
else
        echo "Too many Arguments - Exiting!"
        exit $STATE_CRITICAL
fi

#Check if RoR-Greenlight is running
if [[ -f $RoR_PIDfile ]] ;
then
        RoR_PID=$(cat $RoR_PIDfile)
        RoR_STAT_OUT=$(ps --pid $RoR_PID)
        RoR_Status=$?

        Port_Check=$(nc -z 0.0.0.0 5000)
        Port_Status=$?

        Time_Data=$(echo $RoR_STAT_OUT | cut -d? -f2 | cut -d' ' -f2)
        Time_Data=${Time_Data/:/d}
        Time_Data=${Time_Data/:/h}
        Time_Data="${Time_Data}m"

        if [[ ($RoR_Status = 0) && ($Port_Status = 0) ]];
        then
                RoR_Running="true"
#               echo "Service running with PID: " $RoR_PID
        fi
else
        RoR_Running="false"
#       echo "File doesnt exist - Servic not running"
fi

#Check if nginx is running
NGINX_STRG=$(systemctl status nginx | grep "running")
if [[ ! -z $NGINX_STRG ]];
then
#       echo "NGINX running"
        NGINX_RUN="true"
else
#       echo "NGINX not running"
        NGINX_RUN="false"
fi

#Check if BBB is running
BBB_STRG=$(bbb-conf --status | sed 1,1d | grep -ow 'active')
if [[ ! -z $BBB_STRG ]];
then
        BBB_RUN="true"
else
        BBB_RUN="false"
fi


#START Service if necessary
if [[ $START_VAR = "true" ]];
then
        if [[ $RoR_Running = "true" ]];
        then
                echo 'Greenlight/RubyOnRails allready running!'
                exit $STATE_WARNING
        else
                cd /root/greenlight && /root/.rbenv/shims/rails s -p 5000 -b 0.0.0.0 -d > /dev/null
                echo 'Greenlight/RubyOnRails started on Port 5000!'
                exit $STATE_OK
        fi
fi

#STOP Service if necessary
if [[ $HOLD_VAR = "true" ]];
then
        if [[ $RoR_Running = "true" ]];
        then
                kill $RoR_PID
                echo 'Greenlight/RubyOnRails stopped via PID:' $RoR_PID '!'
                exit $STATE_OK
        else
                echo 'Greenlight/RubyOnRails not running - SKIPPING!'
                exit $STATE_WARNING
        fi
fi

#RESTART Sevice if necessary
if [[ $RESTART_VAR = "true" ]];
then
        if [[ $RoR_Running = "true" ]];
        then
                kill $RoR_PID
                echo 'Greenlight/RubyOnRails stopped via PID:' $RoR_PID '!'
                cd /root/greenlight && /root/.rbenv/shims/rails s -p 5000 -b 0.0.0.0 -d > /dev/null
                echo 'Greenlight/RubyOnRails started on Port 5000!'
                exit $STATE_OK
        else
                echo 'Greenlight/RubyOnRails not running - STARTING ANYWAY!'
                cd /root/greenlight && /root/.rbenv/shims/rails s -p 5000 -b 0.0.0.0 -d > /dev/null
                echo 'Greenlight/RubyOnRails started on Port 5000!'
                exit $STATE_OK
        fi
fi

#STATUS of Service
if [[ ($STATUS_VAR = "true") && ($STATUS_TYPE = "full" ) ]];
then
        if [[ $RoR_Running = "true" ]];
        then
                echo -e '\t+ \e[32m\e[1mGreenlight/RubyOnRails\e[0m\e[32m running on Port 5000 with PID: ' $RoR_PID ' for '$Time_Data'\e[39m'
        else
                echo -e '\t- \e[31m\e[1mGreenlight/RubyOnRails\e[0m\e[31m NOT RUNNING!\e[39m'
        fi

        if [[ $NGINX_RUN = "true" ]];
        then
                echo -e '\t+ \e[32m\e[1mNGINXs\e[0m\e[32m running with systemctl \e[39m'
        else
                echo -e '\t- \e[31m\e[1mNGINX\e[0m\e[31m NOT RUNNING! \e[39m'
        fi

        if [[ $BBB_RUN = "true" ]];
        then
                echo -e '\t+ \e[32m\e[1mBigBlueButton\e[0m\e[32m running with bbb-conf \e[39m'
        else
                echo -e '\t- \e[31m\e[1mBigBlueButton\e[0m\e[31m NOT RUNNING! \e[39m'
        fi

        if [[ ($RoR_Running = "true") && ($NGINX_RUN = "true") && ($BBB_RUN = "true") ]];
        then
                exit $STATE_OK
        else
                exit $STATE_WARN
        fi
elif [[ ( $STATUS_VAR = "true" ) && ( $STATUS_TYPE = "n" ) ]];
then
        if [[ $RoR_Running = "true" ]];
        then
                NAGSTAT="Greenlight/RubyOnRails running on Port 5000 "
        else
                NAGSTAT='Greenlight/RubyOnRails NOT RUNNING! '
                CRIT="true"
        fi

        if [[ $NGINX_RUN = "true" ]];
        then
                NAGSTAT+="; NGINX running with systemctl "
        else
                NAGSTAT+="| NGINX NOT RUNNING! "
                CRIT="true"
        fi

        if [[ $BBB_RUN = "true" ]];
        then
                NAGSTAT+="; BigBlueButton running with bbb-conf "
        else
                NAGSTAT+="| BigBlueButton NOT RUNNING! "
                CRIT="true"
        fi

        echo $NAGSTAT
        if [ -z $CRIT ];
        then
                exit $STATE_OK
        else
                exit $STATE_CRITICAL
        fi
elif [[ ( $STATUS_VAR = "true" ) && ( $STATUS_TYPE = "port" ) ]];
then
        if [[ ($Port_Status = 0) ]];
        then
                echo -e "\e[32mPort 5000 open and waiting for connections!\e[39m"
        else
                echo -e "\e[31mPort 5000 seems to be hung up!\e[39m"
        fi
else
        echo "The Argument you are using after -S is not supported!"
        echo -e ""
        echo -e "Supported Arguments:"
        echo -e "\tfull:\t\tShows full colorized output and data"
        echo -e "\tport:\t\tShows status of greenlight port only"
        echo -e "\tn:\t\tShows output in nagios standard format"
        echo -e ""

        exit $STATE_CRITICAL
fi
