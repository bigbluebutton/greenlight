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

#### Ensure containers are working on local

```shell
curl localhost/b/health_check -v
```

#### Undeploy the container
```
docker-compose -f ./docker-compose-local.yml down
```

