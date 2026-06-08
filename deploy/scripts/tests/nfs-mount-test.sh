#!/usr/bin/env bash

# Скрипт автоматической проверки монтирования NFS
# Запускать с правами sudo/root

# Выходим при любой ошибке (согласно правилам хорошего тона CI/CD)
set -euo pipefail

# --- КОНФИГУРАЦИЯ ---
NFS_SERVER=${NFS_SERVER_IP:-"127.0.0.1"}   # IP сервера NFS (по умолчанию локальный)
NFS_SHARE=${NFS_SHARE_PATH:-"/exports"}    # Экспортируемая папка на сервере
MOUNT_POINT="/mnt/nfs_test_client"         # Точка монтирования на клиенте
TEST_FILE="${MOUNT_POINT}/mount_verification_matrix.txt"

# Цвета для вывода в консоль
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[INFO]${NC} Начинаем интеграционный тест NFS..."

# 1. Создаем локальную директорию для монтирования, если её нет
if [ ! -d "$MOUNT_POINT" ]; then
    echo -e "${GREEN}[INFO]${NC} Создаем точку монтирования: ${MOUNT_POINT}"
    mkdir -p "$MOUNT_POINT"
fi

# 2. Проверяем, не смонтировано ли туда уже что-то (на случай упавших прошлых тестов)
if mountpoint -q "$MOUNT_POINT"; then
    echo -e "${GREEN}[INFO]${NC} Обнаружено старое монтирование. Размонтируем..."
    umount -f "$MOUNT_POINT"
fi

# 3. Пытаемся смонтировать NFS-ресурс
echo -e "${GREEN}[INFO]${NC} Пробуем смонтировать ${NFS_SERVER}:${NFS_SHARE} в ${MOUNT_POINT}..."
if mount -t nfs -o rw,sync,nolock "${NFS_SERVER}:${NFS_SHARE}" "$MOUNT_POINT"; then
    echo -e "${GREEN}[SUCCESS]${NC} Сетевая папка успешно смонтирована!"
else
    echo -e "${RED}[ERROR]${NC} Не удалось смонтировать NFS директорию."
    exit 1
fi

# 4. Проверка прав на запись (Write Test)
echo -e "${GREEN}[INFO]${NC} Проверяем права на запись..."
if echo "NFS Integration Test Passed Successfully at $(date)" > "$TEST_FILE"; then
    echo -e "${GREEN}[SUCCESS]${NC} Файл успешно записан на NFS сервер."
else
    echo -e "${RED}[ERROR]${NC} Ошибка записи на NFS. Проверьте root_squash и права на сервере."
    umount "$MOUNT_POINT"
    exit 1
fi

# 5. Проверка чтения (Read Test)
echo -e "${GREEN}[INFO]${NC} Проверяем чтение записанных данных..."
if [ -f "$TEST_FILE" ] && grep -q "NFS Integration Test" "$TEST_FILE"; then
    echo -e "${GREEN}[SUCCESS]${NC} Данные успешно прочитаны и верифицированы!"
else
    echo -e "${RED}[ERROR]${NC} Ошибка верификации данных при чтении."
    umount "$MOUNT_POINT"
    exit 1
fi

# 6. Подчищаем за собой тестовый файл
rm -f "$TEST_FILE"

# 7. Демонтируем файловую систему
echo -e "${GREEN}[INFO]${NC} Тест завершен. Размонтируем директорию..."
umount "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
    echo -e "${GREEN}[SUCCESS]${NC} Интеграционный тест NFS успешно пройден! Все системы работают штатно."
else
    echo -e "${RED}[WARNING]${NC} Не удалось корректно размонтировать папку после теста."
fi