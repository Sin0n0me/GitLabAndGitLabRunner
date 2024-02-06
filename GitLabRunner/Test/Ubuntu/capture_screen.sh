#!/bin/bash

# 大変助かった
# https://www.ikko-lab.k.hosei.ac.jp/gitbucket/ikko/glx-docker-headless-gpu/tree/9569b65f77cd18fcce5e54d2197267bbf05f4129

FILENAME=$OUTPUT_FILE_DIRECTORY/$(date +'%Y%m%d_%H%M%S').mp4
CAPTURE_TIME=${1:-$DEFAULT_CAPTURE_TIME}

DISPLAY=$VIRTUAL_DISPLAY_NUMBER
export DISPLAY=${VIRTUAL_DISPLAY_NUMBER}.${SCREEN_NUMBER}
export VGL_DISPLAY=${VGL_DISPLAY_NUMBER}

# 仮想ディスプレイの作成
# GPU指定
# 
Xvfb ${VIRTUAL_DISPLAY_NUMBER} -screen $SCREEN_NUMBER ${DISPLAY_SIZE}x${DISPLAY_DEPTH} +extension GLX +render &

# GPUへのアクセス用のディスプレイ
DISPLAY=${VIRTUAL_DISPLAY_NUMBER} VGL_DISPLAY=${VGL_DISPLAY_NUMBER} vglrun glxgears

ffmpeg -hwaccels

sleep 5
xeyes &

sleep 1
xdotool search --name xeyes | xargs xdotool getwindowgeometry | awk -F'[x ]' 'NR==1 {printf $2" "} NR==3 {print (1920-$4)/2, (1080-$5)/2}' | xargs xdotool windowmove

# 実行
./EmulateForLinux &

# スクリーンショットの取得
# -root 画面全体を撮る
# -display ディスプレイ番号
# -out 出力ファイル名
gnome-screenshot --display ${VIRTUAL_DISPLAY_NUMBER} -f ${OUTPUT_FILE_DIRECTORY}/$(date +'%Y%m%d_%H%M%S').png

ls -la $OUTPUT_FILE_DIRECTORY

# 画面キャプチャの実行
# -f 出力するフォーマット
# -t キャプチャ時間
# -r フレームレート
# -s サイズ
# -i スクリーン番号
# -draw_mouse マウスカーソルをキャプチャするか(0:非表示 1:表示)
# -vcodec ビデオコーデック
# -preset エンコードの速度と圧縮率のバランス
# -c:v GPUの指定(キャプチャ時は意味なさそう?要検証)
# 
# 参考など
# https://trac.ffmpeg.org/wiki/Encode/H.264
# 
ffmpeg \
    -f x11grab \
    -t $CAPTURE_TIME \
    -r $CAPTURE_FRAME_RATE \
    -s $DISPLAY_SIZE \
    -i $VIRTUAL_DISPLAY_NUMBER \
    -draw_mouse 1 \
    -show_region 1 \
    -crf 28 \
    -c:v h264_nvenc \
    -vcodec $CAPTURE_VIDEO_CODEC \
    -preset $CAPTURE_PRESET \
    $FILENAME
