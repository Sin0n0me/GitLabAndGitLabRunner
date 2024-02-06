#!/bin/bash

GAME_PROGRAM_PATH=$1
AUTO_OPERATE_SCRIPT_PATH=auto_operate.py
SLEEP_TIME=${2:-300}

# バックグラウンドで実行
GAME_PROGRAM_PATH &

# バックグラウンドで実行するプログラムのプロセスIDの取得
FIRST_PID=$!

# キャプチャの開始
# Xvfbの起動
#Xvfb :99 -screen 0 1280x720x16 &

# キャプチャ用スクリプトの起動
bash ./capture_screen.sh &

# 自動操作スクリプトの実行
$AUTO_OPERATE_SCRIPT_PATH

# キャプチャ終了処理


# プログラムの起動待機時間
sleep $SLEEP_TIME

# 自動操作スクリプトにバグがあった場合, ずっとJobを実行し続けるので特定秒数経過後は強制的にプロセスを殺す
kill $FIRST_PID

