FROM debian:bullseye

ENV CYPRESS_mailHogUrl=http://mailhog:8025 CYPRESS_baseUrl=https://dcc

RUN apt update && apt install --no-install-recommends -y curl chromium xvfb npm wait-for-it
# npm being particular
RUN mkdir -p /root/.cache/Cypress && chmod -R 777 /root

COPY cypress/ /e2e/
WORKDIR /e2e
RUN rm -rf /2e2/node_modules && npm install
RUN ls -ltr && which npm
CMD [ "/bin/bash", "/e2e/cypress-setup.sh"]
