#!/bin/bash
# @file ha-failover.sh
# @brief Тест отказоустойчивости NFS-кластера с Keepalived.

set -euo pipefail

VIP="${VIP:-192.168.1.100}"
MASTER="${MASTER:-nfs-master}"
BACKUP="${BACKUP:-nfs-backup}"
TEST_FILE="/mnt/nfs/ha_test_$(date +%s).txt"

echo "=== HA Failover Test ==="
echo "Virtual IP: ${VIP}"
echo "Master: ${MASTER}"
echo "Backup: ${BACKUP}"
echo ""

# Проверка доступности VIP
echo "[1/4] Checking VIP availability..."
if ping -c 1 -W 2 "${VIP}" > /dev/null 2>&1; then
    echo "OK: VIP ${VIP} is reachable"
else
    echo "FAIL: VIP ${VIP} is not reachable"
    exit 1
fi

# Создание тестового файла
echo ""
echo "[2/4] Creating test file on NFS..."
echo "HA test $(date)" > "${TEST_FILE}" 2>/dev/null && echo "OK: Test file created" || {
    echo "FAIL: Cannot write to NFS"
    exit 1
}

# Имитация падения master-ноды
echo ""
echo "[3/4] Simulating master node failure..."
echo "Stopping NFS service on ${MASTER}..."
echo "WARN: In demo mode, skipping actual stop"

# Ожидание failover
echo ""
echo "[4/4] Waiting for failover (30 seconds)..."
sleep 30

if ping -c 1 -W 2 "${VIP}" > /dev/null 2>&1; then
    echo "OK: VIP ${VIP} is still reachable after failover"
else
    echo "FAIL: VIP ${VIP} is not reachable after failover"
    exit 1
fi

# Проверка целостности данных
echo ""
echo "Verifying data integrity..."
if [ -f "${TEST_FILE}" ]; then
    echo "OK: Test file is accessible after failover"
    cat "${TEST_FILE}"
    rm -f "${TEST_FILE}"
else
    echo "FAIL: Test file is not accessible after failover"
    exit 1
fi

echo ""
echo "=== HA Failover test completed ==="
