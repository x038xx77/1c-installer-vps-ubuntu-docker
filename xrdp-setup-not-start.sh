#!/bin/bash

# sudo chmod +x xrdp-setup-not-start.sh
# Обновление пакетов и установка необходимых зависимостей
sudo apt update && sudo apt upgrade -y

# Установка xrdp и необходимых пакетов
sudo apt install -y xrdp xfce4 xfce4-goodies tightvncserver

# Остановка xrdp, чтобы не запускался автоматически
sudo systemctl stop xrdp

# Отключаем автозапуск xrdp при старте системы
sudo systemctl disable xrdp

# Настроим сеанс рабочего стола, чтобы использовать XFCE
echo "xfce4-session" > ~/.xsession

# Обновим конфигурацию xrdp для использования XFCE
echo "startxfce4" > ~/.xsession

# Включаем xrdp вручную по команде (например, "sudo systemctl start xrdp")
echo "xrdp успешно установлен и настроен. Для запуска используйте команду: sudo systemctl start xrdp"
