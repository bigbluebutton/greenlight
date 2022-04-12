FROM ruby:2.7.5-alpine3.14 AS base

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
# Set Rails environment.
ENV RAILS_ENV production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

# Make the directory and set as working.
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev sqlite-libs sqlite-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"

# Install app dependencies.
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

COPY Gemfile* ./
COPY Gemfile Gemfile.lock $RAILS_ROOT/

RUN bundle config --global frozen 1 \
    && bundle config set deployment 'true' \
    && bundle config set without 'development:test:assets' \
    && bundle install -j4 --path=vendor/bundle
RUN rm -rf vendor/bundle/ruby/2.7.0/cache/*.gem \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.o" -delete

# Adding project files.
COPY . .

# Remove folders not needed in resulting image
RUN rm -rf tmp/cache spec

############### Build step done ###############

FROM base

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
ARG PACKAGES="tzdata curl postgresql-client sqlite-libs yarn nodejs bash gcompat"

ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES


COPY --from=base $RAILS_ROOT $RAILS_ROOT

# Expose port 80.
EXPOSE 80

# Sets the footer of greenlight application with current build version
ARG version_code
ENV VERSION_CODE=$version_code

# Set executable permission to start file
RUN chmod +x bin/start
# Update HTTPClient cacert.pem with the latest Mozilla cacert.pem
RUN wget https://curl.se/ca/cacert.pem https://curl.se/ca/cacert.pem.sha256 -P /tmp
RUN cd /tmp && sha256sum cacert.pem > cacert.pem.sha256sum && cd ${RAILS_ROOT}
RUN diff /tmp/cacert.pem.sha256sum /tmp/cacert.pem.sha256
RUN mv -v /tmp/cacert.pem $(bundle info httpclient --path)/lib/httpclient/ && rm -v /tmp/cacert*

# Update Openssl certs [This is for Faraday adapter for Net::HTTP]
RUN [[ $(id -u) -eq 0 ]] && update-ca-certificates
# Start the application.
CMD ["bin/start"]
