FROM alpine:3.17 AS alpine

ARG RAILS_ROOT=/usr/src/app
ENV RAILS_ROOT=${RAILS_ROOT}

FROM alpine AS base
WORKDIR $RAILS_ROOT
RUN apk add --no-cache \
    libpq \
    libxml2 \
    libxslt \
    ruby \
    ruby-irb \
    ruby-bigdecimal \
    ruby-bundler \
    ruby-json \
    tzdata \
    bash \
    shared-mime-info

FROM base
RUN apk add --no-cache \
    build-base \
    curl-dev \
    git \
    gettext \
    imagemagick \
    libxml2-dev \
    libxslt-dev \
    pkgconf \
    postgresql-dev \
    ruby-dev \
    nodejs npm \
    yarn \
    yaml-dev \
    zlib-dev \
    && ( echo 'install: --no-document' ; echo 'update: --no-document' ) >>/etc/gemrc
COPY . ./
RUN bundle install -j4 \
    && yarn install

ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ARG RAILS_LOG_TO_STDOUT
ENV RAILS_LOG_TO_STDOUT=${RAILS_LOG_TO_STDOUT:-true}
ARG RAILS_SERVE_STATIC_FILES
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES:-true}
ARG PORT
ENV PORT=${PORT:-3000}

EXPOSE ${PORT}

ARG VERSION_TAG
ENV VERSION_TAG=$VERSION_TAG

ENTRYPOINT [ "./bin/start" ]
