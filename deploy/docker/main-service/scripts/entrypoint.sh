#!/bin/bash


set -euo pipefail

echo "[INFO] Запуск административной панели NFS на Streamlit..."

# Запускаем Streamlit на нужном порту
exec streamlit run /app/admin_app.py --server.port 8501 --server.address 0.0.0.0


