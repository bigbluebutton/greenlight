FROM ruby:alpine3.17 AS base

ARG RAILS_ROOT=/usr/src/app
ENV RAILS_ROOT=${RAILS_ROOT}
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ARG NODE_ENV
ENV NODE_ENV=${RAILS_ENV}
ARG RAILS_LOG_TO_STDOUT
ENV RAILS_LOG_TO_STDOUT=${RAILS_LOG_TO_STDOUT:-true}
ARG RAILS_SERVE_STATIC_FILES
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES:-true}
ARG PORT
ENV PORT=${PORT:-3000}
ARG VERSION_TAG
ENV VERSION_TAG=$VERSION_TAG
ENV PATH=$PATH:$RAILS_ROOT/bin
WORKDIR $RAILS_ROOT
RUN bundle config --local deployment 'true' \
    && bundle config --local without 'development:test'

FROM base as build

ARG PACKAGES='alpine-sdk libpq-dev'
COPY Gemfile Gemfile.lock ./
RUN apk update \
    && apk add --update --no-cache ${PACKAGES} \
    && bundle install --no-cache \
    && bundle doctor

FROM base as prod

RUN addgroup -S -g 1000 greenlight && adduser -S -G greenlight -u 999 greenlight

ARG PACKAGES='libpq-dev tzdata imagemagick yarn bash'
COPY --from=build $RAILS_ROOT/vendor/bundle ./vendor/bundle
COPY package.json yarn.lock ./
RUN apk update \
    && apk add --update --no-cache ${PACKAGES} \
    && yarn install --production --frozen-lockfile \
    && yarn cache clean
COPY . ./
RUN apk update \
    && apk upgrade \
    && update-ca-certificates

RUN chown -R greenlight /usr/src/app

USER 999

EXPOSE ${PORT}
ENTRYPOINT [ "./bin/start" ]
