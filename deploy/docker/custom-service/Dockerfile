FROM python:3.9-slim

# Устанавливаем системные утилиты, необходимые для панели администратора
RUN apt-get update && apt-get install -y --no-install-recommends \
    iptables \
    curl \
    systemd \
    dbus \
    nfs-common \
    util-linux \
    python3-pip && \
    pip3 install --no-cache-dir streamlit && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем исходный код панели управления
COPY admin_app.py .
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/healthcheck.sh /healthcheck.sh

# Делаем скрипты исполняемыми
RUN chmod +x /entrypoint.sh /healthcheck.sh

# Настраиваем проверку здоровья контейнера через твой новый скрипт
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD [/healthcheck.sh]

# Точка входа
ENTRYPOINT ["/entrypoint.sh"]