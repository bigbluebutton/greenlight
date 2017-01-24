# Greenlight

Greenlight is a simple front-end application for [BigBlueButton](http://bigbluebutton.org/)

## Usage

Install [docker](https://docs.docker.com/engine/getstarted/step_one/)  
Create an environment variables file, here is a [template with instructions](https://raw.githubusercontent.com/bigbluebutton/greenlight/master/env)  
Start the server in docker

    docker run -d -p 3000:80 -v ${pwd}/db/production --env-file env bigbluebutton/greenlight

You can change the published port (-p) default is 3000  
and the location of the environment variables file (--env-file) default is env
