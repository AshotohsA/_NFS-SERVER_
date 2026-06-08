#!/bin/sh
set -eu

mkdir -p /run/rpcbind
chown rpc:rpc /run/rpcbind 2>/dev/null || true

rpcbind
sleep 2

echo "Starting unfsd..."
exec unfsd -d -e /etc/exports
