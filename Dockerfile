FROM ruby:2.5.1-alpine

# Install app dependencies.
RUN apk update \
&& apk upgrade \
&& apk add --update --no-cache \
build-base curl-dev bash tzdata git postgresql-dev \
yaml-dev sqlite-dev zlib-dev nodejs yarn

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

# Expose port 80.
EXPOSE 80

# Sets the footer of greenlight application with current build version
ARG version_code
ENV VERSION_CODE=$version_code

# Start the application.
CMD ["bin/start"]
