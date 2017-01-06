FROM ruby:2.3.1

# app dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

ENV RAILS_ENV=production \
    APP_HOME=/usr/src/app \
    BIGBLUEBUTTON_ENDPOINT=http://test-install.blindsidenetworks.com/bigbluebutton/ \
    BIGBLUEBUTTON_SECRET=8cd8ef52e8e101574e400365b55e11a6


RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add the greenlight app 
ADD . $APP_HOME

# Install app dependencies
RUN bundle install --without development test doc --deployment --clean
RUN bundle exec rake assets:precompile --trace

CMD ["scripts/default_start.sh"]

