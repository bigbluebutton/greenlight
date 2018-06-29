FROM ruby:2.5

# Install app dependencies.
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs 

# Set an environment variable for the install location.
ENV RAILS_ROOT /usr/src/app
RUN bundle config github.com 0e54e86c4228294d867a0831bff53f95a31d4af2:x-oauth-basic

# Make the directory and set as working.
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

# Set environment variables.
ENV RAILS_ENV production

# Adding project files.
COPY . .

# Install gems.
RUN bundle install --without development test --deployment --clean

# Precompile assets.
RUN bundle exec rake assets:clean
RUN bundle exec rake assets:precompile

# Expose port 3000.
EXPOSE 3000

# Start the application.
CMD ["bin/start"]
