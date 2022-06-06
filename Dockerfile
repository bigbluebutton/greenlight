FROM alpine:3.16 AS alpine

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
    libxml2-dev \
    libxslt-dev \
    pkgconf \
    postgresql-dev \
    sqlite-libs \
    sqlite-dev \
    ruby-dev \
    nodejs npm \
    yarn \
    yaml-dev \
    zlib-dev \
    && ( echo 'install: --no-document' ; echo 'update: --no-document' ) >>/etc/gemrc
COPY . ./
RUN bundle install -j4 \
    && yarn install \
    && ./node_modules/.bin/esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds

ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ARG RAILS_LOG_TO_STDOUT
ENV RAILS_LOG_TO_STDOUT=${RAILS_LOG_TO_STDOUT:-true}
ARG RAILS_SERVE_STATIC_FILES
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES:-true}

ARG VERSION_CODE
ENV VERSION_CODE=$VERSION_CODE

EXPOSE 3000

ENTRYPOINT [ "./bin/start" ]
