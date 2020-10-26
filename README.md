# Greenlight

You can find some general information about the Greenlight in its [official repository](https://github.com/bigbluebutton/greenlight).

## Installing Greenlight with SAML support
First, create the Greenlight directory for its configuration to live in.

`mkdir ~/greenlight && mkdir ~/greenlight/cert && mkdir ~/greenlight/cert/idp && cd ~/greenlight`

Greenlight will read its environment configuration from the .env file. To generate this file and install the Greenlight Docker image, run:

`docker run --rm intecsoft/greenlight-saml:v2 cat ./sample.env > .env`
  
### Configuration

#### Create .env configuration
In `greenlight` folder use command `cp sample.env .env`

#### Generating a Secret Key
Greenlight needs a secret key in order to run in production. To generate this, run:

`docker run --rm intecsoft/greenlight-saml:v2 bundle exec rake secret`

Inside your .env file, set the SECRET_KEY_BASE option to the last line in the output this command. You don’t need to wrap it in quotation marks.

#### Setting BigBlueButton Credentials
By default, your Greenlight instance will automatically connect to the test-install.blindsidenetworks.com if no BigBlueButton credentials are specified. To set Greenlight to connect to your BigBlueButton server (the one it’s installed on), you need to give Greenlight the endpoint and the secret. 

`bbb-conf --secret`

In your .env file, set the BIGBLUEBUTTON_ENDPOINT to the URL, and set BIGBLUEBUTTON_SECRET to the secret.

#### Set SAML configuration
See [SAMLconfiguration.md](https://github.com/intecsoft/greenlight/blob/master/SAMLconfiguration.md) 

#### Configure Nginx to Route To Greenlight
Use [documentation](https://docs.bigbluebutton.org/greenlight/gl-customize.html#4-configure-nginx-to-route-to-greenlight) 

#### Get docker-compose file
`docker run --rm intecsoft/greenlight-saml:v2 cat ./docker-compose.yml > docker-compose.yml`

#### Configure docker-compose file for your settings
Change environment variables for PostgreSQL container with login, password, and database name.

#### Change DB connection settings in .env file
If Greenlight should work not with the default settings of the database, please, change the DB connection settings in the .env file.

## Start
`docker-compose up -d`

## Stop
`docker-compose down`

## Help
Use [Documentation](https://docs.bigbluebutton.org/greenlight/gl-customize.html) if you need any further help.
