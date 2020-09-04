# Greenlight

![Travis CI](https://travis-ci.org/bigbluebutton/greenlight.svg?branch=master)
![Coverage
!Status](https://coveralls.io/repos/github/bigbluebutton/greenlight/badge.svg?branch=master)
![Docker Pulls](https://img.shields.io/docker/pulls/bigbluebutton/greenlight.svg)

Greenlight is a simple front-end interface for your BigBlueButton server. At it's heart, Greenlight provides a minimalistic web-based application that allows users to:

  * Signup/Login with Google, Office365, or through the application itself.
  * Manage your account settings and user preferences.
  * Create and manage your own personal rooms ([BigBlueButton](https://github.com/bigbluebutton/bigbluebutton) sessions).
  * Invite others to your room using a simple URL.
  * View recordings and share them with others.

Interested? Try Greenlight out on our [demo server](https://demo.bigbluebutton.org/gl)!

Greenlight is also completely configurable. This means you can turn on/off features to make Greenlight fit your specific use case. For more information on Greenlight and its features, see our [documentation](http://docs.bigbluebutton.org/greenlight/gl-install.html).

For a overview of how Greenlight works, checkout our Introduction to Greenlight Video:

[![GreenLight Overview](https://img.youtube.com/vi/Hso8yLzkqj8/0.jpg)](https://youtu.be/Hso8yLzkqj8)

## Installation on a BigBlueButton Server

Greenlight is designed to work on a [BigBlueButton 2.0](https://github.com/bigbluebutton/bigbluebutton) (or later) server.

For information on installing Greenlight, checkout our [Installing Greenlight on a BigBlueButton Server](http://docs.bigbluebutton.org/greenlight/gl-install.html#installing-on-a-bigbluebutton-server) documentation.

## Source Code & Contributing

Greenlight is built using Ruby on Rails. Many developers already know Rails well, and we wanted to create both a full front-end to BigBlueButton but also a reference implementation of how to fully leverage the [BigBlueButton API](http://docs.bigbluebutton.org/dev/api.html).

We invite you to build upon Greenlight and help make it better. See [Contributing to BigBlueButton](http://docs.bigbluebutton.org/support/faq.html#contributing-to-bigbluebutton).

We invite your feedback, questions, and suggests about Greenlight too. Please post them to the [developer mailing list](https://groups.google.com/forum/#!forum/bigbluebutton-dev).

## Configuration and Deploy
### Configuration
#### Create .env configuration
In `greenlight` folder use command `cp sample.env .env`
#### Generating a Secret Key
Greenlight needs a secret key in order to run in production. To generate this, run:

`docker run --rm bigbluebutton/greenlight:v2 bundle exec rake secret`

Inside your .env file, set the SECRET_KEY_BASE option to the last line in this command. You don’t need to surround it in quotations.

#### Setting BigBlueButton Credentials
By default, your Greenlight instance will automatically connect to test-install.blindsidenetworks.com if no BigBlueButton credentials are specified. To set Greenlight to connect to your BigBlueButton server (the one it’s installed on), you need to give Greenlight the endpoint and the secret. 

`bbb-conf --secret`

In your .env file, set the BIGBLUEBUTTON_ENDPOINT to the URL, and set BIGBLUEBUTTON_SECRET to the secret.

#### Change DB connection settings in .env file
#### Configure Nginx to Route To Greenlight
Use [documentation](https://docs.bigbluebutton.org/greenlight/gl-customize.html#4-configure-nginx-to-route-to-greenlight) 
#### Build docker image
`./scripts/image_build.sh <image name> release-v2`
#### Convigure docker-compose file for your settings
## Start
`docker-compose up -d`

## Stop
`docker-compose down`


## In case of code changes:
    1. docker-compose down
    2. ./scripts/image_build.sh <image name> release-v2
    3. docker-compose up -d


## Help
use [Documentation](https://docs.bigbluebutton.org/greenlight/gl-customize.html) if you need a help