FROM ruby:2.5

# Install app dependencies.
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set an environment variable for the install location.
ENV RAILS_ROOT /usr/src/app

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

# Expose port 80.
EXPOSE 80

# Start the application.
CMD ["bin/start"]
