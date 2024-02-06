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

# GitLabコンテナ名の取得
GITLAB_CONTAINER_NAME=$(grep "GITLAB_CONTAINER_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
IMAGE_ID=$(sudo docker ps -a --filter name=${GITLAB_CONTAINER_NAME} --format "{{.ID}}")

while true; do
    # コンテナのヘルスステータスの有無を確認
    if sudo docker inspect --format='{{.State.Health.Status}}' $IMAGE_ID &>/dev/null; then
        HEALTH_STATUS=$(sudo docker ps -a --filter name=${GITLAB_CONTAINER_NAME} --format='{{.State.Health.Status}}')
    else
        HEALTH_STATUS="starting" # デフォルトの状態を仮定
    fi

    STATUS=$(sudo docker ps -a --filter name=${GITLAB_CONTAINER_NAME} --format="{{.State}}" | tr -d '[:space:]')
    # コンテナのステータスがrunning以外の場合は終了
    if [ "$STATUS" != "running" ]; then
        echo "Container status is not running. Status: $STATUS"
        exit 1
    fi

    # ヘルスステータスがhealthyの場合はループを抜ける
    if [ "$HEALTH_STATUS" == "healthy" ]; then
        break
    fi

    sleep 5
done

# ファイルから直接得たrootのパスワードを使用してGitLab生成用のトークンを取得する
# ここはなんとかしたいが今のところ方法が思いつかないので有識者に相談したいところ...
GITLAB_DATA_DIRECTORY=$(grep "GITLAB_DATA_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
ROOT_PASSWORD=$(sudo grep "Password: " ${CONFIG_PATH}${GITLAB_DATA_DIRECTORY}/config/initial_root_password | cut -d': ' -f2-)

# ランナー作成用のトークンを取得し生成

# Runnerの追加
BUILD_TOOLS=("MSBuild" "Cmake")
OS=("Windows" "Linux")
for os in "${OS[@]}"; do
    for tool in "${BUILD_TOOLS[@]}"; do
        # Dockerfileの生成
        ./create_docker_compose.sh ${CONFIG_FILE} ${os} ${tool}
        if [ $? -ne 0 ]; then
            exit 1
        fi

        # トークンを引数に渡したくないのでこのスクリプト内で生成する

        sudo docker compose -d --build
    done
done
