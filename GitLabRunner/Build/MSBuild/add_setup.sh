#!/bin/bash

# Dockerfileが存在しなければ何もしない
if [ ! -e "Dockerfile" ]; then
    echo "Dockerfile does not exist"
    #exit 1
fi

DOCKERFILE="\
# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive WINEPREFIX=/root/.wine WINEARCH=win64

# 依存関係のインストール
RUN dpkg --add-architecture i386 && \ 
    apt-get update && apt-get install -y --no-install-recommends \ 
    wine64 wine32 winetricks \ 
    git wget mono-complete ca-certificates && \ 
    rm -rf /var/lib/apt/lists/*

# Nugetの追加
RUN apt-get update && apt-get install -y \ 
    nuget \ 
    && apt-get update

# Protonのセットアップする場合はコメントを外す
# RUN git clone --recurse-submodules https://github.com/ValveSoftware/Proton.git proton

# MSBuildのセットアップ
# Visual Studio Build Tools のダウンロード
RUN curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe

# Wine を使用してインストーラを実行
# VS2022を想定した場合のインストール
# https://learn.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2022
RUN wine vs_buildtools.exe --quiet --wait --norestart --nocache \ 
    --includeRecommended \ 
    --installPath 'C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools' \ 
    --add Microsoft.VisualStudio.Workload.VCTools \ 
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \ 
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \ 
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \ 
    --remove Microsoft.VisualStudio.Component.Windows81SDK || true

# ファイルのクリーンアップ
RUN rm -f vs_buildtools.exe
"

echo "${DOCKERFILE}" >>"Dockerfile"
