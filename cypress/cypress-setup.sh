#!/bin/bash

if [ -d /e2e ] ; then
  cd /e2e
fi
pwd
if [ -d node_modules ]; then
  rm -rf node_modules
fi

apt update && apt install --no-install-recommends -y curl chromium xvfb npm wait-for-it
mkdir -p /root/.cache/Cypress
chmod -R 777 /root
pwd
ls -la
npm install
export CYPRESS_mailHogUrl=http://mailhog:8025
export CYPRESS_baseUrl=https://dcc
exec npm run test

