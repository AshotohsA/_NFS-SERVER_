FROM python:3.9-slim

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
COPY . .

# Запуск Streamlit
CMD ["streamlit", "run", "admin_app.py", "--server.port", "8501", "--server.address", "0.0.0.0"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8501/_stcore/health || exit 1
