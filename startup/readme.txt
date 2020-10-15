#########################################################################################
#											#
#	+ Greenlight StartUp Script for deployment with ruby on rails +			#
#											#
#	This set of scripts is meant to ease the deployment of a 			#
#	BigBlueButton/Greenlight instance running on ruby on rails in 			#
#	stead of docker. In order to get a working solution on a hosted			#
#	plattform (e.g.: Strato) this may be crucial since docker is 			#
#	blocked from running on many hosters linux kernels.				#
#											#
#			Installation: ./setup-script.sh					#
#											#
#########################################################################################

Step 1: What is to be expected:
	- Starting, stopping and restarting the rails service
	- Fetching port and status information for the service and its dependecies
	- Generating nagios or terminal output

Step 2: What does the setup-script.sh do:
	- Copy the greenlight script to the right path to be included
	- Modify the execution flags of the script
	- Set cron to start on reboot
	- Set cron to clear the cache daily

Step 3: Dependencies:
	- Greenlight must be installed in /root/greenlight/
	- RoR must be installed in /root/.rbenv/
	- Target port 5000 is free to use and not blocked
