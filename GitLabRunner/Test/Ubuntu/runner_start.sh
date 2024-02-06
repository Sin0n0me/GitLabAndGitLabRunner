#!/bin/bash

if [ $# != 2 ]; then
	echo "runner_start.sh <token> <runner name>"
	exit 1
fi

TOKEN=$1
RUNNER_NAME=$2
LENGTH=8
SERVER_URL=https://gitlab.sin0n0me.com
CA_FILE=/etc/gitlab-runner/certs/gitlab_sin0n0me_ca.crt

# Xvfbの起動
Xvfb $VIRTUAL_DISPLAY_NUMBER -screen 0 $DISPLAY_SIZE &

# Runnerの登録
gitlab-runner register \
--non-interactive \
--url $SERVER_URL \
--tag-list \
--registration-token $TOKEN \
--executor docker \
--docker-image ubuntu:22.04 \
--name $RUNNER_NAME \
--docker-privileged \
--tls-ca-file $CA_FILE

# 使用したので意味のない文字で埋める
export TOKEN=hogehoge

# Runnerの実行
gitlab-runner run \
--user=gitlab-runner \
--working-directory=/home/gitlab-runner

