FROM ruby:2.7.2-alpine AS base

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
ARG RAILS_GREENLIGHT_USER=greenlight
# Set Rails environment.
ENV RAILS_ENV production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev sqlite-libs sqlite-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"

# Install app dependencies.
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES
RUN addgroup "$RAILS_GREENLIGHT_USER"
RUN adduser --disabled-password --ingroup "$RAILS_GREENLIGHT_USER" \
      --home "$RAILS_ROOT" --no-create-home "$RAILS_GREENLIGHT_USER"

RUN mkdir -p $RAILS_ROOT && chown $RAILS_GREENLIGHT_USER $RAILS_ROOT
# Make the directory and set as working.
WORKDIR $RAILS_ROOT


COPY Gemfile* ./
COPY Gemfile Gemfile.lock $RAILS_ROOT/

RUN bundle config --global frozen 1 \
    && bundle install --deployment --without development:test:assets -j4 --path=vendor/bundle \
    && rm -rf vendor/bundle/ruby/2.7.0/cache/*.gem \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.o" -delete

# Adding project files.
COPY . .
RUN chown -R "$RAILS_GREENLIGHT_USER:$RAILS_GREENLIGHT_USER" .
# Remove folders not needed in resulting image
RUN rm -rf tmp/cache spec
USER $RAILS_GREENLIGHT_USER

############### Build step done ###############

FROM ruby:2.7.2-alpine

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
ARG PACKAGES="tzdata curl postgresql-client sqlite-libs yarn nodejs bash"

ARG RAILS_GREENLIGHT_USER=greenlight
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

RUN addgroup "$RAILS_GREENLIGHT_USER"
RUN adduser --disabled-password --ingroup "$RAILS_GREENLIGHT_USER" \
      --home "$RAILS_ROOT" --no-create-home "$RAILS_GREENLIGHT_USER"

RUN mkdir -p $RAILS_ROOT && chown $RAILS_GREENLIGHT_USER $RAILS_ROOT
# Make the directory and set as working.
WORKDIR $RAILS_ROOT
COPY --from=base $RAILS_ROOT $RAILS_ROOT
RUN chown -R "$RAILS_GREENLIGHT_USER:$RAILS_GREENLIGHT_USER" .
USER $RAILS_GREENLIGHT_USER
# Expose port 80.
EXPOSE 3000

# Sets the footer of greenlight application with current build version
ARG version_code
ENV VERSION_CODE=$version_code

# Start the application.
CMD ["bin/start"]
