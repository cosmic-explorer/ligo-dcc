#!/bin/bash

if [ -d /e2e ] ; then
  cd /e2e
fi
apt update && apt install --no-install-recommends -y curl chromium xvfb npm wait-for-it
mkdir -p /root/.cache/Cypress
chmod -R 777 /root


rm -rf node_modules

npm install
npx browserslist@latest --update-db

wait-for-it mariadb:3306 -- echo "mariadb ready"
wait-for-it mailhog:8025 -- echo "mailhog ready"
wait-for-it dcc:443      -- echo "dcc ready"
exec npm run test
