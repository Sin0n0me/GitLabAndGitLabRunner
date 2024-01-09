#!/bin/bash

CERTIFICATE_FILE_NAME="gitlab_sin0n0me_certificate"

# 移動(Dockerfile側で移動させたい...)
cp subject.cnf /etc/pki/subject.cnf

# docker-compose側で設定したボリュームに移動
cd /etc/pki

# CAの秘密鍵を生成
openssl genrsa -out $CERTIFICATE_FILE_NAME.key 4096

# 証明書署名要求(CSR)の作成
openssl req -new -key $CERTIFICATE_FILE_NAME.key -out $CERTIFICATE_FILE_NAME.csr -config subject.cnf

# 自己署名ルート証明書を生成
# 期限は180日にする
# SANsの情報も含める
openssl x509 -req -days 180 -in $CERTIFICATE_FILE_NAME.csr -signkey $CERTIFICATE_FILE_NAME.key -out $CERTIFICATE_FILE_NAME.crt -extensions v3_req -extfile subject.cnf

# 確認用
openssl x509 -in $CERTIFICATE_FILE_NAME.crt -text -noout
