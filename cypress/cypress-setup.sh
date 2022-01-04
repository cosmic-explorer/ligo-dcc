#!/bin/bash

if [ -d /e2e ] ; then
  cd /e2e
fi

if [ -d node_modules ]; then
  rm -rf node_modules
fi

apt update && apt install -y chromium xvfb npm
mkdir -p /root/.cache/Cypress
chmod -R 777 /root

npm install
export CYPRESS_mailHogUrl=http://mailhog:8025
exec npm run test

