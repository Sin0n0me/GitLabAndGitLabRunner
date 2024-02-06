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
SELF_SIGNED_CERTIFICATE_CONTAINER_NAME=$(grep "SELF_SIGNED_CERTIFICATE_CONTAINER_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_DIRECTORY=$(grep "CERTIFICATE_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)

# docker-compose.ymlの作成
DOCKER_COMPOSE_YML="\
version: '${DOCKER_COMPOSE_VERSION}'

services:
  # 自己署名証明書(いわゆるオレオレ証明書)の作成
  gitlab-self-signed-certificate:
    build:
      context: ./
      dockerfile: Dockerfile
    container_name: ${SELF_SIGNED_CERTIFICATE_CONTAINER_NAME}
    hostname: ${SELF_SIGNED_CERTIFICATE_CONTAINER_NAME}
    volumes:
      - \"${CONFIG_PATH}${CERTIFICATE_DIRECTORY}:/etc/pki\" # 鍵保管用のボリューム割り当て
"

echo "${DOCKER_COMPOSE_YML}" > "docker-compose.yml"
