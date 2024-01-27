# gitlab/gitlab-runner:latestはubunutをベースとしている
# https://docs.gitlab.com/runner/install/docker.html#docker-images
FROM gitlab/gitlab-runner:latest
WORKDIR /test_runner

# 環境変数の設定
ENV DISPLAY=:99

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

#RUN apt-get install -y software-properties-common 

# packageのリポジトリ情報が古いと怒られる
RUN apt-get update 

# 必要なツール類を取得
# git 自作テストツール等のスクリプト取得用
# xvfb 仮想ディスプレイ作成用 
# python3.9 マウスやキーボード操作などの自動テスト用
# gnome-screenshot スクリーンショット用
# x11-apps 
RUN apt-get install -y \ 
    git \
    xvfb \
    gnome-screenshot \
    ffmpeg \
    python3.9 \
    x11-apps \
    && apt-get update

# 以下はX11Libによる自動操作用ライブラリとコンパイル用ツール
# cmake
# build-essential
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
RUN git clone -b develop https://github.com/Sin0n0me/AutoGameControl.git

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

# あまりよくないがrootユーザでないとXvfbが起動できない
# なるべくroot権限でなくとも仮想ディスプレイを作成できるような仕組みにしたい
USER root

# コンテナ起動時にXvfbを起動
ENTRYPOINT ["./capture_screen.sh"]
# ENTRYPOINT ["./runner_start.sh"]