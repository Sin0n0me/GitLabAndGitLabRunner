#!/bin/bash

if [ $# != 1 ]; then
	echo "token must be specified"
	exit 1
fi

# Runnerの名前を決定
RANDOM=openssl rand -hex ${LENGTH}
RUNNER_NAME="runner_$RANDOM"
echo "name: $RUNNER_NAME"

cd GitLabRunner

echo "TOKEN=$1" > .env
echo "RUNNER_NAME=$RUNNER_NAME" >> .env

# ビルド後構築
sudo docker compose build
sudo docker compose up -d

# トークンが含まれる.envファイルは削除
rm .env

cd ../
