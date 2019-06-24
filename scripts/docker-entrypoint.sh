#! /bin/bash
set -e

if [ -z "$1" ]; then
  set -- bundle exec puma -C config/puma.rb "$@"
fi

exec "$@"
