FROM alpine:3.12

COPY entrypoint.sh /entrypoint.sh

RUN apk --update add --no-cache bash openssh-client sshpass curl \
  && chmod +x /entrypoint.sh && rm -rf /var/cache/apk/*

ENTRYPOINT ["/entrypoint.sh"]