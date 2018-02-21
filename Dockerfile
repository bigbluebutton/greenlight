FROM ruby:2.4.0

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
RUN bundle exec rake db:migrate
#RUN bundle exec rake db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1
#RUN bundle exec rake db:seed
RUN bundle exec rake assets:precompile --trace

CMD ["scripts/default_start.sh"]
