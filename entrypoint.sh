#!/usr/bin/env sh

cp -R /app/public/* /static/

rm -rf tmp/pids

exec "$@"
