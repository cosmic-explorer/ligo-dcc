#!/bin/bash

if [ -d /e2e ] ; then
  cd /e2e
fi
apt update && apt install --no-install-recommends -y curl chromium xvfb npm wait-for-it
mkdir -p /root/.cache/Cypress
chmod -R 777 /root

npm install
exec npm run test
