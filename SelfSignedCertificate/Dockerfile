# 軽量なAlpine Linuxを使う(Ubuntuよりかなり軽い)
# 認証以外の機能は不要なので必要最小限にする
FROM alpine:latest
WORKDIR /workdir

RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*
RUN apk add --no-cache bash

COPY subject.cnf subject.cnf
COPY generate_key.sh generate_key.sh

RUN chmod +x generate_key.sh

ENTRYPOINT [ "./generate_key.sh" ]
