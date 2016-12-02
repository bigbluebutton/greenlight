#!/bin/bash

echo "module Greenlight VERSION = ${CIRCLE_BUILD_NUM} end" >| $HOME/greenlight/app/lib/version.rb
