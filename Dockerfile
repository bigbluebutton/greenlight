FROM ruby:2.5

# Install app dependencies.
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl

ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg

RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg && \
echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list &&  \
curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
apt-get update && apt-get install -y nodejs yarn

# Set an environment variable for the install location.
ENV RAILS_ROOT /usr/src/app

# Make the directory and set as working.
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

# Set Rails environment.
ENV RAILS_ENV production

COPY Gemfile* ./
RUN bundle install --without development test --deployment --clean

# Adding project files.
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE="$(bundle exec rake secret)" bundle exec rake assets:clean
RUN SECRET_KEY_BASE="$(bundle exec rake secret)" bundle exec rake assets:precompile

# Expose port 80.
EXPOSE 80

# Sets the footer of greenlight application with current build version
ARG version_code
ENV VERSION_CODE=$version_code

# Start the application.
CMD ["bin/start"]
