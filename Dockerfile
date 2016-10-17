FROM ruby:2.3.1

# app dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# app directory
RUN mkdir /usr/src/app
