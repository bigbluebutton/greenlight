# Connecting from the local host to the DEV database

## Pre-requisites

* docker
* docker-compose
* postgres-client

## Verify

* Verify if you are able to connect to the following URL

```shell
telnet dev-db-link-greenlight.veeaplatform.net 5432
```

####  Use the PSQL Client with the specfied username and password of the database to connect and check to see if the client is able to query. 

This should prompt you for a password
```
psql -h dev-db-link-greenlight.veeaplatform.net -p 5432 -U <DB_USER_NAEM>-d <DB_NAME> -W
```

### Using the docker-compose for local development

The following commands can be used to deploy your changes.

This reads the Dockerfile in the current directory to build an image. There are 2 client configurations
related to this particular use case.

* veea-nj
* remax

Modify the following file before starting development: 

```shell
    env_file: local-veea-nj.env
    env_file: local-remax.env
```
#### Build the docker image locally

```shell
docker-compose -f ./docker-compose-local.yml build
```
#### Deploy the image locally in detached mode 
```shell
docker-compose -f ./docker-compose-local.yml up -d
```

#### View logs in the container

To view logs in the container use the following command

```shell
docker-compose -f ./docker-compose-local.yml logs -f greenlight
```

#### Ensure containers are working on local

```shell
curl localhost/b/health_check -v
```

#### Execute a command in the shell

You can execute a command like this to check to see which environment you are connected to or to run other 
commands inside the shell.

```shell
$ docker-compose -f ./docker-compose-local.yml exec greenlight env
PATH=/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=5bf96136f8c8
TERM=xterm
BIGBLUEBUTTON_ENDPOINT=https://scalelite.adedge.dev.veeaplatform.net
BIGBLUEBUTTON_SECRET=6dd734c18eb3cce306a1ef2bb540a317fe75f93609b946adad9979eecd45e28c
DB_ADAPTER=postgresql
DB_HOST=dev-db-link-greenlight.veeaplatform.net
DB_NAME=dev_adedge_greenlight_veea_nj
DB_PASSWORD=XKGYHyAZiSgOY
DB_PORT=5432
DB_USERNAME=dev_adedge_greenlight_veea_nj
SECRET_KEY_BASE=c63ca46c930fb2b753b76dc03356f797dde68bf0501f58c20c9efc1f34f9bbc87dca590421f8a283463bb99fa825b021ab4be18bdd83c21f86680f869072c2b2
SMTP_AUTH=login
SMTP_DOMAIN=veea.co
SMTP_PASSWORD=fEON-scf5Eep2N5JAQ7YrA
SMTP_PORT=587
SMTP_SENDER=vreo@veea.co
SMTP_SERVER=smtp.mandrillapp.com
SMTP_STARTTLS_AUTO=true
SMTP_USERNAME=info@sceneapp.io
SMTP_TEST_RECIPIENT=vreo@veea.co
WEB_CONCURRENCY=1
LANG=C.UTF-8
RUBY_MAJOR=2.7
RUBY_VERSION=2.7.2
RUBY_DOWNLOAD_SHA256=1b95ab193cc8f5b5e59d2686cb3d5dcf1ddf2a86cb6950e0b4bdaae5040ec0d6
GEM_HOME=/usr/local/bundle
BUNDLE_SILENCE_ROOT_WARNING=1
BUNDLE_APP_CONFIG=/usr/src/app/.bundle
RAILS_ENV=production
INVITE_PREFIX=/frontend
RAILS_LOG_TO_STDOUT=true
RELATIVE_URL_ROOT=/b
ALLOW_GREENLIGHT_ACCOUNTS=true
ALLOW_MAIL_NOTIFICATIONS=true
CABLE_ADAPTER=postgresql
DEFAULT_REGISTRATION=open
ENABLE_SSL=false
ROOM_FEATURES=mute-on-join,require-moderator-approval,anyone-can-start,all-join-moderator,recording
VERSION_CODE=
```

#### Undeploy the container
```
docker-compose -f ./docker-compose-local.yml down
```

#### Setting up datagrip or another SQL Editor

Setting up data grip or another SQL Editor can be done using the environment variables described above. 


### References

* The database reverse proxy is mapped to the following Route 53 domain->dev-db-link-greenlight.veeaplatform.net.
* The route 53 points to a reverse proxy instance running nginx on EC2.
*  The reverse proxy listens to the port and redirects requests to 