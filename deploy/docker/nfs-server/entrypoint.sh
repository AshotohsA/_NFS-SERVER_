#!/bin/sh
# @file entrypoint.sh
# @brief Скрипт инициализации и запуска NFS-сервера версии 4.
# @details Запускает только демон NFSv4 через sudo, отключая устаревшие rpcbind.
# @author [Твои ФИО] (твоя_почта@university.com)
# @date 2026-06-06
# @version 1.0.0
# @license MIT

# Режим безопасного выполнения (требование методички)
set -eu

# Запускаем NFSv4 используя sudo (так как мы под пользователем nfsusr)
sudo /usr/sbin/rpc.nfsd 4
sudo /usr/sbin/exportfs -arv

# Держим контейнер запущенным бесконечно
tail -f /dev/null
