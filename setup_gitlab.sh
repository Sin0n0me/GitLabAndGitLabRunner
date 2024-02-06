#!/bin/bash

CONFIG_FILE="gitlab.config"

# コンフィグファイルが存在しない場合は終了
if [ ! -e ${CONFIG_FILE} ]; then
	echo "${CONFIG_FILE} does not exist"
	exit 1
fi

# shファイルのみ実行権限を付与
sudo find . -type f -name "*.sh" -exec chmod +x {} \;

# 証明書ファイルが存在しなければ生成
CERTIFICATE_DIRECTORY=$(grep "CERTIFICATE_DIRECTORY=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_FILE_NAME=$(grep "CERTIFICATE_FILE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_FILE="${CERTIFICATE_DIRECTORY}/${CERTIFICATE_FILE_NAME}.crt"
if [ ! -e "$CERTIFICATE_FILE" ]; then
	cd SelfSignedCertificate
	./setup_self_signed_certificate.sh "../${CONFIG_FILE}"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	cd ../
fi

# GitLabのdocker-compose.ymlの生成
./GitLab/create_docker_compose.sh "${CONFIG_FILE}"

# GitLab構築
sudo docker compose up -d --build

# もしRunner用のDNSが設定されていない場合はDNSの構築を始める
if [ -z $(grep "DNS_ADDRESS=" ${CONFIG_FILE} | cut -d'=' -f2-) ]; then
	cd DNS
	# 不要では?
	# ./setup_dns.sh "../${CONFIG_FILE}"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	cd ../
fi

# GitLab Runner 構築
cd GitLabRunner
./setup_gutlab_runner.sh "../${CONFIG_FILE}"
cd ../
