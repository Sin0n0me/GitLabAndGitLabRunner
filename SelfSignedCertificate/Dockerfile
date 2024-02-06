# 軽量なAlpine Linuxを使う(Ubuntuより軽い)
# 証明書作成以外の機能は不要なので必要最小限にする
FROM alpine:latest
WORKDIR /workdir

RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*
RUN apk add --no-cache bash

COPY subject.cnf subject.cnf
COPY generate_key_and_certificate.sh generate_key_and_certificate.sh

RUN chmod +x generate_key_and_certificate.sh

ENTRYPOINT [ "./generate_key_and_certificate.sh" ]
