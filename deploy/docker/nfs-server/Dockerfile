# @file Dockerfile
# @brief Сборка минимального и безопасного образа NFS-сервера.
# @details Используется Alpine Linux, принцип наименьших привилегий (non-root).
# @author 
# @date 2026-06-06
# @version 1.0.0
# @license MIT

FROM alpine:3.19

RUN apk add --no-cache nfs-utils sudo

RUN addgroup -S nfsgrp && adduser -S nfsusr -G nfsgrp

RUN echo "nfsusr ALL=(root) NOPASSWD: /usr/sbin/rpc.nfsd, /usr/sbin/exportfs" > /etc/sudoers.d/nfsusr \
    && chmod 0440 /etc/sudoers.d/nfsusr

RUN mkdir -p /srv/nfs/share && chown -R nfsusr:nfsgrp /srv/nfs/share

COPY exports /etc/exports
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && chown nfsusr:nfsgrp /entrypoint.sh

EXPOSE 2049

USER nfsusr

ENTRYPOINT ["/entrypoint.sh"]
