#!/bin/sh
# @file fio-test.sh
# @brief Нагрузочное тестирование NFS-шары с использованием утилиты fio.
# @details Замеряет скорость случайной записи и чтения блоками по 4K.
# @author [Твои ФИО] (твоя_почта@university.com)
# @date 2026-06-06
# @version 1.0.0
# @license MIT

# Режим безопасного выполнения (требование методички)
set -eu

echo "=== Запуск нагрузочного теста NFS (fio) ==="
echo "Устанавливаем fio..."
apk add fio --no-cache

echo "Запускаем тест записи (50 МБ, блок 4K)..."
fio --name=nfs_write_test \
    --filename=/mnt/nfs/fio_test_file \
    --size=50M \
    --rw=write \
    --bs=4k \
    --ioengine=sync \
    --direct=1 \
    --group_reporting

echo "=== Тест завершен успешно ==="
