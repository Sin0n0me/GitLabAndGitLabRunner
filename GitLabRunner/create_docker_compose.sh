#!/bin/bash

# 引数がなければ終了
if [ $# != 3 ]; then
  echo "$0 <config file path> <os> <compiletool>"
  exit 1
fi

# コンフィグファイルが存在しない場合は終了
CONFIG_FILE=$1
if [ ! -e ${CONFIG_FILE} ]; then
  echo "${CONFIG_FILE} does not exist"
  exit 1
fi
CONFIG_PATH=$(dirname "$CONFIG_FILE")

# Dockerfileの生成
./create_dockerfile.sh $1 $2 $3

# Runnerの名前を決定
LENGTH=12
RANDOM=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c ${LENGTH})

DOCKER_COMPOSE_VERSION=$(grep "DOCKER_COMPOSE_VERSION=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_TEST_RUNNER_SERVICE_NAME=$(grep "GITLAB_TEST_RUNNER_SERVICE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
PREFIX_TEST_RUNNER=$(grep "PREFIX_TEST_RUNNER=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_TEST_RUNNER_CONTAINER_NAME=$(grep "GITLAB_TEST_RUNNER_CONTAINER_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_TEST_RUNNER_HOST_NAME=$(grep "GITLAB_TEST_RUNNER_HOST_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
GITLAB_RUNNER_DATA_DIRECTORY=$(grep "GITLAB_RUNNER_DATA_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_DIRECTORY=$(grep "CERTIFICATE_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_FILE_NAME=$(grep "CERTIFICATE_FILE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
VIRTUAL_DISPLAY_NUMBER=$(grep "VIRTUAL_DISPLAY_NUMBER=" ${CONFIG_FILE} | cut -d'=' -f2-)
VGL_DISPLAY_NUMBER=$(grep "VGL_DISPLAY_NUMBER=" ${CONFIG_FILE} | cut -d'=' -f2-)
SCREEN_NUMBER=$(grep "SCREEN_NUMBER=" ${CONFIG_FILE} | cut -d'=' -f2-)
DISPLAY_SIZE=$(grep "DISPLAY_SIZE=" ${CONFIG_FILE} | cut -d'=' -f2-)
DISPLAY_DEPTH=$(grep "DISPLAY_DEPTH=" ${CONFIG_FILE} | cut -d'=' -f2-)
CAPTURE_FRAME_RATE=$(grep "CAPTURE_FRAME_RATE=" ${CONFIG_FILE} | cut -d'=' -f2-)
DEFAULT_CAPTURE_TIME=$(grep "DEFAULT_CAPTURE_TIME=" ${CONFIG_FILE} | cut -d'=' -f2-)
CAPTURE_VIDEO_CODEC=$(grep "CAPTURE_VIDEO_CODEC=" ${CONFIG_FILE} | cut -d'=' -f2-)
CAPTURE_PRESET=$(grep "CAPTURE_PRESET=" ${CONFIG_FILE} | cut -d'=' -f2-)

RUNNER_NAME="${PREFIX_TEST_RUNNER}${RANDOM}"
echo "name: $RUNNER_NAME"

# docker-compose.ymlの作成
DOCKER_COMPOSE_YML="\
version: '${DOCKER_COMPOSE_VERSION}'

services:
  ${GITLAB_TEST_RUNNER_SERVICE_NAME}:
    build: 
      context: ./
      dockerfile: Dockerfile
    container_name: '${GITLAB_TEST_RUNNER_CONTAINER_NAME}${RANDOM}'
    hostname: '${GITLAB_TEST_RUNNER_HOST_NAME}${RANDOM}'
    restart: unless-stopped # alwaysでもいいかもしれない?
    volumes:
      - ./output:\${OUTPUT_FILE_DIRECTORY}:rw
      - ${RUNNER_NAME}${GITLAB_RUNNER_DATA_DIRECTORY}/config/${RUNNER_NAME}:/etc/gitlab-runner:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro # dockerコマンド認識用
      - ${CONFIG_PATH}${CERTIFICATE_DIRECTORY}/${CERTIFICATE_FILE_NAME}.crt:/etc/gitlab-runner/certs/${CERTIFICATE_FILE_NAME}.crt:ro
    environment:
      - VIRTUAL_DISPLAY_NUMBER=${VIRTUAL_DISPLAY_NUMBER}
      - VGL_DISPLAY_NUMBER=${VGL_DISPLAY_NUMBER}
      - SCREEN_NUMBER=${SCREEN_NUMBER}
      - DISPLAY_SIZE=${DISPLAY_SIZE}
      - DISPLAY_DEPTH=${DISPLAY_DEPTH}
      - CAPTURE_FRAME_RATE=${CAPTURE_FRAME_RATE}
      - DEFAULT_CAPTURE_TIME=${DEFAULT_CAPTURE_TIME}
      - CAPTURE_VIDEO_CODEC=${CAPTURE_VIDEO_CODEC}
      - CAPTURE_PRESET=${CAPTURE_PRESET}
      - RUNNER_NAME=${RUNNER_NAME}
      - OUTPUT_FILE_DIRECTORY=/etc/output   # 出力ディレクトリ
"

echo "${DOCKER_COMPOSE_YML}" > "docker-compose.yml"

# GPUが存在すればアクセス可能にする
#./write_gpu_access.sh
