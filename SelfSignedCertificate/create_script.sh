#!/bin/bash

# 引数がなければ終了
if [ $# != 1 ]; then
    echo "$0 <config file path>"
    exit 1
fi

# コンフィグファイルが存在しない場合は終了
CONFIG_FILE=$1
if [ ! -e ${CONFIG_FILE} ]; then
	echo "${CONFIG_FILE} does not exist"
	exit 1
fi

# 証明書のファイル名取得
CERTIFICATE_FILE_NAME=$(grep "CERTIFICATE_FILE_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
CERTIFICATE_EXPIRATION_DATE=$(grep "CERTIFICATE_EXPIRATION_DATE=" ${CONFIG_FILE} | cut -d'=' -f2-)

SCRIPT="\
#!/bin/bash

# 移動
cp subject.cnf /etc/pki/subject.cnf

# docker-compose側で設定したボリュームに移動
cd /etc/pki

# CAの秘密鍵を生成
openssl genrsa -out ${CERTIFICATE_FILE_NAME}.key 4096

# 証明書署名要求(CSR)の作成
openssl req -new -key ${CERTIFICATE_FILE_NAME}.key -out ${CERTIFICATE_FILE_NAME}.csr -config subject.cnf

# 自己署名ルート証明書を生成
# 期限は180日にする
# SANsの情報も含める
openssl x509 -req -days $CERTIFICATE_EXPIRATION_DATE -in ${CERTIFICATE_FILE_NAME}.csr -signkey ${CERTIFICATE_FILE_NAME}.key -out ${CERTIFICATE_FILE_NAME}.crt -extensions v3_req -extfile subject.cnf

# 確認用
openssl x509 -in ${CERTIFICATE_FILE_NAME}.crt -text -noout
"

echo "${SCRIPT}" > "generate_key_and_certificate.sh"