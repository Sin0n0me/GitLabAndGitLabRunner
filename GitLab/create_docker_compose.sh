#!/bin/bash

# 引数がなければ終了
if [ $# != 1 ]; then
    echo "$0 <config file path>"
    exit 1
fi

# コンフィグファイルが存在しない場合は終了
CONFIG_FILE=$1
if [ ! -e ${CONFIG_FILE} ]; then
    echo "${CONFIG_FILE} does not exist"
    exit 1
fi
CONFIG_PATH=$(dirname "$CONFIG_FILE")

DOCKER_COMPOSE_VERSION=$(grep "DOCKER_COMPOSE_VERSION=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_SERVICE_NAME=$(grep "GITLAB_SERVICE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_CONTAINER_NAME=$(grep "GITLAB_CONTAINER_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_HOST_NAME=$(grep "GITLAB_HOST_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_DATA_DIRECTORY=$(grep "GITLAB_DATA_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_DIRECTORY=$(grep "CERTIFICATE_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_FILE_NAME=$(grep "CERTIFICATE_FILE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
HTTPS_PORT=$(grep "HTTPS_PORT=" ${CONFIG_FILE} | cut -d'=' -f2-)
SSH_PORT=$(grep "SSH_PORT=" ${CONFIG_FILE} | cut -d'=' -f2-)
DOMAIN_NAME=$(grep "DOMAIN_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_NETWORK_NAME=$(grep "GITLAB_NETWORK_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)

# docker-compose.ymlの作成
DOCKER_COMPOSE_YML="\
version: '${DOCKER_COMPOSE_VERSION}'

services:
  ${GITLAB_SERVICE_NAME}:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    container_name: ${GITLAB_CONTAINER_NAME}
    hostname: ${GITLAB_HOST_NAME}
    volumes:
      - ${CONFIG_PATH}${GITLAB_DATA_DIRECTORY}/config:/etc/gitlab:rw
      - ${CONFIG_PATH}${GITLAB_DATA_DIRECTORY}/logs:/var/log/gitlab:rw
      - ${CONFIG_PATH}${GITLAB_DATA_DIRECTORY}/data:/var/opt/gitlab:rw
      # 以下は読み取り専用にする
      - ${CONFIG_PATH}${CERTIFICATE_DIRECTORY}/${CERTIFICATE_FILE_NAME}.crt:/etc/gitlab/ssl/${CERTIFICATE_FILE_NAME}.crt:ro
      - ${CONFIG_PATH}${CERTIFICATE_DIRECTORY}/${CERTIFICATE_FILE_NAME}.key:/etc/gitlab/ssl/${CERTIFICATE_FILE_NAME}.key:ro
    ports:
      - '${HTTPS_PORT}:443'
      - '${SSH_PORT}:22'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://${DOMAIN_NAME}'
        nginx['enable'] = true
        nginx['redirect_http_to_https'] = true
        letsencrypt['enable'] = false
        nginx['listen_port'] = 443
        gitlab_rails['gitlab_shell_ssh_port'] = ${SSH_PORT}
        nginx['ssl_certificate'] = '/etc/gitlab/ssl/${CERTIFICATE_FILE_NAME}.crt'
        nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/${CERTIFICATE_FILE_NAME}.key'
    network_mode: bridge

networks:
    ${GITLAB_NETWORK_NAME}:
      internal: true
"

echo "${DOCKER_COMPOSE_YML}" > "docker-compose.yml"
