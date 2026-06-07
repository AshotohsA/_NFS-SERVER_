# NFS-SERVER — Курсовой проект по администрированию Linux

##Тема 15: Использование NFS-сервера для сетевого хранения данных

### Описание
Проект разворачивает отказоустойчивый NFSv4-сервер на базе Alpine Linux в Docker-контейнерах.
Клиенты монтируют общее хранилище через нативный Docker Volume Driver, минуя установку пакетов внутрь контейнеров.

### Стек технологий
- **ОС:** Alpine Linux 3.19 (LTS)
- **Протокол:** NFSv4 (без устаревших rpcbind/mountd)
- **Оркестрация:** Docker Compose
- **Тестирование:** fio (нагрузочное тестирование IOPS/Latency)

### Быстрый старт
```bash
cd deploy
docker compose up -d --build
```

### Проверка работоспособности
```bash
docker exec -it client-1 sh
df -h | grep nfs
echo "Test from client-1" > /mnt/nfs/test.txt
exit

docker exec -it client-2 sh
cat /mnt/nfs/test.txt
exit
```

### Лицензирование
- Исходный код автоматизации: **MIT**
- Технический отчет: **CC BY-SA 4.0**
