#!/bin/bash

rake db:migrate

exec bundle exec puma -C config/puma.rb
