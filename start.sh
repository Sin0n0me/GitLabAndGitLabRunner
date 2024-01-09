#!/bin/bash

CERTIFICATE_FILE="./data/pki/gitlab_sin0n0me_certificate.crt"

if [ ! -e  "$CERTIFICATE_FILE" ]; then
	cd SelfSignedCertificate
	sudo docker compose build
	sudo docker compose up
	cd ../
fi

IMAGE_ID=$(sudo docker ps -a --filter name=self-signed-certificate --format "{{.ID}}")
STATUS=$(sudo docker inspect --format='{{.State.Status}}' $IMAGE_ID)

while [ "$STATUS" != "exited" ]; do
    sleep 5 # 5秒ごとにチェック
    STATUS=$(sudo docker inspect --format='{{.State.Status}}' $IMAGE_ID)
done

# 終了時に証明書がなければ終了
if [ ! -e  "$CERTIFICATE_FILE" ]; then
	echo "Certificate does not exist"
	exit 1
fi

sudo docker compose build
sudo docker compose up -d

