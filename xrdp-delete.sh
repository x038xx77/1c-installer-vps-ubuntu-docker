#!/bin/bash

# Остановка службы xrdp
sudo systemctl stop xrdp

# Отключение автозапуска службы xrdp
sudo systemctl disable xrdp

# Удаление xrdp и зависимостей
sudo apt-get purge -y xrdp xfce4 xfce4-goodies tightvncserver

# Очистка неиспользуемых зависимостей и пакетов
sudo apt-get autoremove -y
sudo apt-get clean

# Удаление оставшихся конфигурационных файлов
sudo rm -rf /etc/xrdp
sudo rm -rf ~/.xsession

# Завершаем скрипт
echo "xrdp и все его зависимости были успешно удалены."
