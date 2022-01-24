FROM debian:bullseye

ENV CYPRESS_mailHogUrl=http://mailhog:8025 \
    CYPRESS_baseUrl=https://dcc

RUN apt update && apt install --no-install-recommends -y curl chromium firefox-esr xvfb npm wait-for-it gnupg2
ADD https://packages.microsoft.com/keys/microsoft.asc /cache/microsoft.asc
RUN gpg --dearmor </cache/microsoft.asc >/cache/microsoft.gpg  && \
    install -o root -g root -m 644 /cache/microsoft.gpg /etc/apt/trusted.gpg.d/  &&\
    echo 'deb [arch=amd64] https://packages.microsoft.com/repos/edge/ stable main' > /etc/apt/sources.list.d/microsoft-edge.list &&\
    apt update && apt install -y  microsoft-edge-stable

# npm being particular
RUN mkdir -p /root/.cache/Cypress && chmod -R 777 /root

COPY cypress/ /e2e/
WORKDIR /e2e
RUN rm -rf /2e2/node_modules && npm install
RUN ls -ltr && which npm
CMD [ "/bin/bash", "/e2e/cypress-setup.sh"]
