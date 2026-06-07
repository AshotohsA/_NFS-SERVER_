#!/bin/sh
# @file entrypoint.sh
# @brief Скрипт инициализации и запуска NFS-сервера версии 4.
# @details Запускает только демон NFSv4 через sudo, отключая устаревшие rpcbind.
# @author 
# @date 2026-06-06
# @version 1.0.0
# @license MIT

set -eu

sudo /usr/sbin/rpc.nfsd 4
sudo /usr/sbin/exportfs -arv

tail -f /dev/null
