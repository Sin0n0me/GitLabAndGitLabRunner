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

# subject.confの生成
./create_subject.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi

# 証明書生成用スクリプトの作成
./create_script.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi

# docker-compose.ymlの作成
./create_docker_compose.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi

# 自己署名証明書を作成するコンテナの起動
sudo docker compose up --build

# コンテナイメージの取得
SELF_SIGNED_CERTIFICATE_CONTAINER_NAME=$(grep "SELF_SIGNED_CERTIFICATE_CONTAINER_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
IMAGE_ID=$(sudo docker ps -a --filter name=${SELF_SIGNED_CERTIFICATE_CONTAINER_NAME} --format "{{.ID}}")
STATUS=$(sudo docker inspect --format='{{.State.Status}}' $IMAGE_ID)

# 証明書の生成が完了するまで待機
while [ "$STATUS" != "exited" ]; do
    sleep 5 # 5秒ごとにチェック
    STATUS=$(sudo docker inspect --format='{{.State.Status}}' $IMAGE_ID)
done

# 終了時に証明書がなければ異常終了
CERTIFICATE_DIRECTORY=$(grep "CERTIFICATE_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_FILE_NAME=$(grep "CERTIFICATE_FILE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_FILE="${CONFIG_PATH}${CERTIFICATE_DIRECTORY}/${CERTIFICATE_FILE_NAME}.crt"
if [ ! -e  "${CERTIFICATE_FILE}" ]; then
    echo "${CERTIFICATE_FILE} does not exist"
    exit 1
fi
