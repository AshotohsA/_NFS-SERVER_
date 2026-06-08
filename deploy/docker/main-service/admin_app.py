import streamlit as st
import subprocess
import ipaddress
import os
import time

st.set_page_config(page_title="NFS Admin Panel", page_icon="🛡️")

st.title("🛡️ NFS Cluster Admin Control")

# 1. Функция проверки IP
def is_valid_ip(ip):
    try:
        ipaddress.ip_address(ip)
        return True
    except ValueError:
        return False

# 2. Функция управления фаерволом
def run_iptables(command, ip):
    if not is_valid_ip(ip):
        return False, "Неверный формат IP!"
    try:
        # Для блокировки должен приходить "-I" (Insert), для разблокировки "-D" (Delete)
        subprocess.run(["iptables", command, "INPUT", "-s", ip, "-p", "tcp", "--dport", "2049", "-j", "DROP"],
                       check=True, capture_output=True, text=True)
        return True, "Успешно применено"
    except subprocess.CalledProcessError as e:
        return False, f"Ошибка iptables: {e.stderr}"

# 3. Функция получения списка клиентов
def get_connected_clients():
    try:
        # Добавляем -e (показывать только смонтированные), чтобы избежать лишнего шума
        # Если showmount всё равно не видит, можно попробовать явно указать localhost
        result = subprocess.run(["showmount", "-a", "localhost"], capture_output=True, text=True)
        return result.stdout.strip().split('\n') if result.stdout.strip() else []
    except Exception as e:
        return [f"Ошибка: {e}"]

# 4. Функция управления службой nfs-server

def manage_nfs_service(action):
    # Метод для D-Bus
    method = "StartUnit" if action == "start" else "StopUnit"

    # Команда отправки
    cmd_send = [
        "nsenter", "-t", "1", "-m", "-u", "-i", "-n", "-p",
        "dbus-send", "--system", "--print-reply",
        "--dest=org.freedesktop.systemd1",
        "/org/freedesktop/systemd1",
        f"org.freedesktop.systemd1.Manager.{method}",
        "string:nfs-server.service",
        "string:replace"
    ]

    try:
        # 1. Отправляем команду (check=False, чтобы не падать при мелких предупреждениях)
        subprocess.run(cmd_send, check=False, capture_output=True, text=True)

        # Даем системе время подумать
        time.sleep(2)

        # 2. Проверяем состояние
        cmd_check = [
            "nsenter", "-t", "1", "-m", "-u", "-i", "-n", "-p",
            "systemctl", "is-active", "nfs-server"
        ]
        result = subprocess.run(cmd_check, capture_output=True, text=True)
        status = result.stdout.strip()

        # 3. Логика успеха
        if action == "start" and status == "active":
            return True, "✅ Сервер NFS успешно запущен!"

        elif action == "stop" and status != "active":
            return True, "⏹️ Сервер NFS успешно остановлен!"

        # Если статус не совпал с ожиданиями, выводим его, но не "кричим" об ошибке
        else:
            return True, f"Команда отправлена. Текущий статус сервера: {status}"

    except Exception as e:
        # Ошибка будет только если что-то совсем сломалось (например, nsenter не найден)
        return False, f"Техническая ошибка выполнения: {str(e)}"
# --- ИНТЕРФЕЙС ---

# Секция мониторинга
st.subheader("🌐 Подключенные NFS-клиенты:")
clients = get_connected_clients()
if clients:
    for client in clients:
        st.write(f"🟢 {client}")
else:
    st.info("Активных подключений нет (или используется NFSv4).")

st.divider()

# Секция управления сервером
st.subheader("⚙️ Управление сервером NFS:")
col_s1, col_s2 = st.columns(2)
with col_s1:
    if st.button("▶️ Запустить NFS"):
        success, msg = manage_nfs_service("start")
        if success: st.success(msg)
        else: st.error(msg)
with col_s2:
    if st.button("⏹️ Остановить NFS"):
        success, msg = manage_nfs_service("stop")
        if success: st.success(msg)
        else: st.error(msg)

st.divider()

# Секция управления доступом (блокировка)
st.subheader("🔒 Блокировка доступа:")
ip_input = st.text_input("Введите IP для блокировки/разблокировки:")

col1, col2 = st.columns(2)
with col1:
    if st.button("🚫 Заблокировать"):
        # ВАЖНО: используем -I, чтобы правило встало на 1-е место и сразу заблокировало!
        success, msg = run_iptables("-I", ip_input)
        if success: st.success(msg)
        else: st.error(msg)
with col2:
    if st.button("✅ Разблокировать"):
        success, msg = run_iptables("-D", ip_input)
        if success: st.success(msg)
        else: st.error(msg)

# Секция отладки правил
st.subheader("📋 Активные правила DROP:")
try:
    result = subprocess.run(["iptables", "-L", "INPUT", "-n", "--line-numbers"], capture_output=True, text=True)
    st.code(result.stdout)
except Exception as e:
    st.error(f"Не удалось прочитать iptables: {e}")
