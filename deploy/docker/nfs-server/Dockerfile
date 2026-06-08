# @file Dockerfile
# @brief Сборка User-Space NFS-сервера (unfs3) для WSL2.

FROM alpine:3.19

RUN apk add --no-cache unfs3 rpcbind

RUN mkdir -p /srv/nfs/share && chmod 777 /srv/nfs/share

COPY exports /etc/exports
RUN chmod 644 /etc/exports

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2049

CMD ["/entrypoint.sh"]
