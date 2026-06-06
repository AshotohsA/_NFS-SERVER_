# @file Dockerfile
# @brief Сборка минимального и безопасного образа NFS-сервера.
# @details Используется Alpine Linux, принцип наименьших привилегий (non-root).
# @author [Твои ФИО] (твоя_почта@university.com)
# @date 2026-06-06
# @version 1.0.0
# @license MIT

FROM alpine:3.19

# Устанавливаем nfs-utils и sudo, очищаем кэш (требование методички)
RUN apk add --no-cache nfs-utils sudo

# Создаем непривилегированного пользователя и группу
RUN addgroup -S nfsgrp && adduser -S nfsusr -G nfsgrp

# Настраиваем sudo, чтобы nfsusr мог запускать nfsd и exportfs БЕЗ пароля
RUN echo "nfsusr ALL=(root) NOPASSWD: /usr/sbin/rpc.nfsd, /usr/sbin/exportfs" > /etc/sudoers.d/nfsusr \
    && chmod 0440 /etc/sudoers.d/nfsusr

# Создаем директорию для шары и назначаем владельца (безопасность)
RUN mkdir -p /srv/nfs/share && chown -R nfsusr:nfsgrp /srv/nfs/share

# Копируем конфиги
COPY exports /etc/exports
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && chown nfsusr:nfsgrp /entrypoint.sh

EXPOSE 2049

# ПЕРЕКЛЮЧАЕМСЯ НА НЕПРИВИЛЕГИРОВАННОГО ПОЛЬЗОВАТЕЛЯ (Строго по методичке!)
USER nfsusr

ENTRYPOINT ["/entrypoint.sh"]
