# gitlab/gitlab-runner:latestはubunutをベースとしている
# > gitlab/gitlab-runner:latest based on Ubuntu.
# https://docs.gitlab.com/runner/install/docker.html#docker-images
FROM gitlab/gitlab-runner:latest
WORKDIR /test_runner

# ユーザ作成しないとMust not run with sudoで怒られる
RUN useradd -m runner
RUN chmod 777 -R .

# ツール取得前に更新
RUN apt-get update && apt-get upgrade -y
RUN apt-get update 

# 全てのRunnerに共通して存在するツールの取得
# git OSSなどのclone用
# curl ファイル取得用
# xvfb 仮想ディスプレイ作成用 
# ffmpeg 動画キャプチャ用
# xdotool 
# libglu1-mesa 
# libegl1-mesa 
RUN apt-get install -y \
    git \
    curl \
    xvfb \
    gnome-screenshot \
    ffmpeg \
    xdotool \
    libglu1-mesa \
    libegl1-mesa \
    && apt-get update

# 以下はX11Libによる自動操作用ライブラリとコンパイル用ツール
# cmake
# g++
# gcc
# libx11-dev 
# libxtst-dev
RUN apt-get install -y \ 
    cmake \
    g++ \
    gcc \
    libx11-dev \
    libxtst-dev \
    && apt-get update

# コンパイラ設定
ENV CC=/usr/bin/gcc \
    CXX=/usr/bin/g++

# 自作自動操作プログラムの取得とコンパイル
RUN ls && git clone -b develop https://github.com/Sin0n0me/AutoGameControl.git

# コンパイル & 成果物移動
RUN cd AutoGameControl/EmulateForLinux/build \
    && bash ./release_build.sh \
    && cd ../../../ \
    && cp AutoGameControl/EmulateForLinux/build/EmulateForLinux EmulateForLinux \
    && chmod +x EmulateForLinux

# 画面キャプチャのスクリプト
COPY Test/capture_screen.sh capture_screen.sh
RUN chmod +x capture_screen.sh

# runnerとXvfb起動用スクリプト
COPY Test/runner_start.sh runner_start.sh
RUN chmod +x runner_start.sh
