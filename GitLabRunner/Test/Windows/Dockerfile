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

# wget ファイル取得用
# software-properties-common 外部リポジトリの取得用
# apt-transport-https httpsでの取得用
# curl ファイル取得用
RUN apt-get install -y \
    wget \
    apt-transport-https \
    curl \
    && apt-get update

# packageのリポジトリ情報が古いと怒られる
RUN apt-get update 

# Windowsアプリケーションを起動するためのパッケージのインストール
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends wine32 wine64

# 必要なツール類を取得
# git 自作テストツール等のスクリプト取得用
# xvfb 仮想ディスプレイ作成用 
# ffmpeg 動画キャプチャ用
# python3.9 マウスやキーボード操作などの自動テスト用
# gnome-screenshot スクリーンショット用
# x11-apps 
# xdotool 
# libglu1-mesa 
# libegl1-mesa 
#
RUN apt-get install -y \ 
    git \
    xvfb \
    gnome-screenshot \
    ffmpeg \
    python3.9 \
    x11-apps \
    xdotool \
    libglu1-mesa \
    libegl1-mesa \
    && apt-get update

# Wine の設定
RUN winecfg

# VirtualGLのインストール
# https://github.com/VirtualGL/virtualgl/releases
# amd64
# arm64
# i386
RUN curl -L -o virtualgl.deb https://github.com/VirtualGL/virtualgl/releases/download/3.1/virtualgl_3.1_amd64.deb
RUN dpkg -i virtualgl.deb

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
COPY capture_screen.sh capture_screen.sh
RUN chmod +x capture_screen.sh

# runnerとXvfb起動用スクリプト
COPY runner_start.sh runner_start.sh
RUN chmod +x runner_start.sh

COPY captured_inputs.txt captured_inputs.txt

# コンテナ起動時にXvfbを起動
ENTRYPOINT ["./capture_screen.sh"]
# ENTRYPOINT ["./runner_start.sh"]