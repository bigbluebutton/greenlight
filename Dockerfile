FROM ruby:2.3.1

# app dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

ENV RAILS_ENV=production \
    APP_HOME=/usr/src/app


RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add the greenlight app
ADD . $APP_HOME

# Install app dependencies
RUN bundle install --without development test doc --deployment --clean
RUN bundle exec rake assets:precompile --trace

CMD ["scripts/default_start.sh"]
