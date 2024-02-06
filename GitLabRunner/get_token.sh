#!/bin/bash

# 必要な引数が足りているかチェック
if [ "$#" -ne 3 ]; then
    echo "How to use: $0 <personal token> <project or group URL> <bash path to pass the token>"
    exit 1
fi

ACCESS_TOKEN=$1
URL=$2
BASH_PATH=$3

# GitLabのドメインを抽出
GITLAB_DOMAIN=$(echo $URL | awk -F/ '{print $3}')

# URLのパス部分を抽出(先頭の/は削除)
# https://gitlab.sin0n0me.com/hoge/fuga であれば hoge/fuga
# https://gitlab.sin0n0me.com/hoge であれば hoge/
URL_PATH=$(echo $URL | awk -F/ '{print substr($0, index($0,$4))}')

# URLエンコードされたパスを生成
ENCODED_URL_PATH=$(echo $URL_PATH | sed -e 's/\//%2F/g')

# スラッシュの数によってグループかプロジェクトかを判断
SLASH_COUNT=$(grep -o "/" <<<"$URL_PATH" | wc -l)

# 1. プロジェクトかグループかを判定
# 2. GroupもしくはProjectIDの取得
# 3. 対応するAPI URLを生成
API_URL=""
if [ $SLASH_COUNT -eq 1 ]; then
    # グループの場合
    GROUP_PATH=$(echo $URL_PATH | cut -d/ -f1)
    RESPONSE=$(curl --silent --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "https://$GITLAB_DOMAIN/api/v4/groups/$GROUP_PATH")
    GROUP_ID=$(echo $RESPONSE | jq '.id')
    API_URL="https://${GITLAB_DOMAIN}/api/v4/groups/${ENCODED_URL_PATH}/runners"
    echo "グループID: $GROUP_ID"
elif [ $SLASH_COUNT -eq 2 ]; then
    # プロジェクトの場合
    # URLエンコードされたパスを生成
    PROJECT_PATH=$(echo $URL_PATH | sed 's#/#%2F#g')
    RESPONSE=$(curl --silent --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "https://$GITLAB_DOMAIN/api/v4/projects/$PROJECT_PATH")
    PROJECT_ID=$(echo $RESPONSE | jq '.id')
    API_URL="https://${GITLAB_DOMAIN}/api/v4/projects/${ENCODED_URL_PATH}/runners"
    echo "プロジェクトID: $PROJECT_ID"
else
    echo "URLが正しくありません。"
    exit 1
fi

echo $API_URL

# APIリクエストを実行してRunner認証トークンを取得
# --insecureだとどのhttpsでも検証しなくなるので対応必要(一旦完成優先)
curl --request POST "$API_URL" \
    --header "PRIVATE-TOKEN: $ACCESS_TOKEN" \
    --form "description=Test" \
    --form "tag_list=linux"

RUNNER_TOKEN=$(curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" --insecure "${API_URL}")

echo $RUNNER_TOKEN

# 指定したbashにトークンを渡す
#bash $BASH_PATH
