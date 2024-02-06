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

# ホスト名の取得
DOMAIN_NAME=$(grep "DOMAIN_NAME=" ${CONFIG_FILE} | cut -d'=' -f2-)
SUBJECT_FILE="subject.cnf"

SUBJECT="\
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_req
prompt             = no

[ req_distinguished_name ]
C  = JP
ST = Tokyo
L  = Chiyoda City
O  = Sin0n0me Land
OU = Sin0n0me san
CN = ${DOMAIN_NAME}

[ req_ext ]
subjectAltName = @alt_names

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1   = ${DOMAIN_NAME}
"

echo "${SUBJECT}" > "${SUBJECT_FILE}"
