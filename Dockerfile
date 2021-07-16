FROM ruby:2.7.2 AS base

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
# Set Rails environment.
ENV RAILS_ENV production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

# Make the directory and set as working.
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ARG BUILD_PACKAGES="build-essential curl git"
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
ARG DEV_PACKAGES="libpq-dev libsqlite3-dev libyaml-dev zlib1g-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ARG STREAMING_PACKAGE="curl gnupg2 psmisc ffmpeg  make g++ libgbm-dev ffmpeg gconf-service libasound2 libatk1.0-0 libc6 libcairo2 \
                                        libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
                                        libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
                                        libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
                                        libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
                                        libxtst6 ca-certificates fonts-liberation libappindicator1  libnss3 \
                                        lsb-release xdg-utils wget xvfb fonts-noto \
                                        dbus-x11 libasound2 fluxbox  libasound2-plugins alsa-utils  alsa-oss pulseaudio pulseaudio-utils \
                                         xvfb pulseaudio-equalizer "

RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -y update
RUN apt-get -y install google-chrome-stable

#RUN apt-get -y install software-properties-common
#RUN add-apt-repository ppa:bigbluebutton/support 

# install -y app dependencies.
RUN apt update \
    && apt upgrade -y \
    && apt install -y $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES 

COPY Gemfile* ./
COPY Gemfile Gemfile.lock $RAILS_ROOT/

RUN bundle config --global frozen 1 \
    && bundle install  --deployment --without development:test:assets -j4 --path=vendor/bundle \
    && rm -rf vendor/bundle/ruby/2.7.0/cache/*.gem \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.o" -delete

# installing project files.
COPY . .

# Remove folders not needed in resulting image
RUN rm -rf tmp/cache spec

############### Build step done ###############

FROM ruby:2.7.2

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
ARG PACKAGES="tzdata curl postgresql-client libsqlite3-dev  yarn nodejs bash"

ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
ARG STREAMING_PACKAGE="curl gnupg2 psmisc  ffmpeg  make g++ libgbm-dev ffmpeg gconf-service libasound2 libatk1.0-0 libc6 libcairo2 \
                                        libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
                                        libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
                                        libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
                                        libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
                                        libxtst6 ca-certificates fonts-liberation libappindicator1  libnss3 \
                                        lsb-release xdg-utils wget xvfb fonts-noto \
                                        dbus-x11 libasound2 fluxbox  libasound2-plugins alsa-utils  alsa-oss pulseaudio pulseaudio-utils \
                                         xvfb "
RUN apt update \
    && apt upgrade -y \
    && apt install -y $PACKAGES $STREAMING_PACKAGE
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -y update
RUN apt-get -y install google-chrome-stable

COPY --from=base $RAILS_ROOT $RAILS_ROOT

# Expose port 80.
EXPOSE 80

# Sets the footer of greenlight application with current build version
ARG version_code
ENV VERSION_CODE=$version_code

# install node dependencies
RUN cd bbb-live-streaming && npm install

# Start the application.

CMD ["bin/start"]