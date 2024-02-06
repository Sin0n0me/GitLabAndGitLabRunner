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

OS=$2
COMPILE_TOOL=$3

# 先にベース部分のDockerfileからコピー
cp Base/Dockerfile Dockerfile

# 引数に応じて応じてツールなど追加のセットアップを行う
if [ ${COMPILE_TOOL} == "MSBuild" ]; then
  ./Build/MSBuild/add_setup.sh
elif [ ${COMPILE_TOOL} == "CMake" ]; then
  ./Build/CMake/add_setup.sh
fi

# テスト用設定のインストール
if [ ${OS} == "Windows" ]; then
  ./Build/MSBuild/add_setup.sh
elif [ ${OS} == "Linux" ]; then
  ./Build/CMake/add_setup.sh
fi

# 
if [ $? -ne 0 ]; then
  exit 1
fi
