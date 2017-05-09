[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/bigbluebutton/greenlight/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/bigbluebutton/greenlight/?branch=master)
[![Build Status](https://scrutinizer-ci.com/g/bigbluebutton/greenlight/badges/build.png?b=master)](https://scrutinizer-ci.com/g/bigbluebutton/greenlight/build-status/master)
[![CircleCI](https://circleci.com/gh/bigbluebutton/greenlight.svg?style=shield)](https://circleci.com/gh/bigbluebutton/greenlight)

# Greenlight

GreenLight is a simple (but powerful) front-end interface for your BigBlueButton server.  At its core, GreenLight provides a minimalistic web-based application that lets users

  * Create a meeting
  * Invite others to the meeting
  * Join a meeting

Furthermore, if you configure GreenLight to use either Google or Twitter for authentication (via OAuth2), users can login to record meetings and manage recordings.

## Overview video

For a overview of how GreenLight works, see the following video

[![GreenLight Overview](https://img.youtube.com/vi/yGX3JCv7OVM/0.jpg)](https://youtu.be/yGX3JCv7OVM)


## Installation on the BigBlueButton server
We designed GreenLight to install on a [BigBlueButton 1.1-beta](http://docs.bigbluebutton.org/1.1/install.html) (or later) server.  This means you don't need a separate server to run GreenLight.

For more informaiton see [Installing GreenLight](http://docs.bigbluebutton.org/1.1/green-light.html).

# Source Code

GreenLight is a rails 5 application.   

Many developers already know Rails well, and we wanted to create both a full front-end to BigBlueButton but also a reference implementation of how to fully leverage the [BigBlueButton API](http://docs.bigbluebutton.org/dev/api.html).

We invite you to build upon GreenLight and help make it better.  See [Contributing to BigBlueButton](http://docs.bigbluebutton.org/support/faq.html#contributing-to-bigbluebutton).

We invite your feedback, questions, and suggests about GreenLight too.  Please post them to the [developer mailing list](https://groups.google.com/forum/#!forum/bigbluebutton-dev).
