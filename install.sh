#!/bin/bash

# Загружаем переменные окружения из файла .env
if [ -f "/env/.env" ]; then
    source /env/.env
else
    echo "Файл .env не найден. Убедитесь, что он доступен в контейнере."
    exit 1
fi

# Проверяем наличие пути к установочному файлу
if [ -z "$INSTALLER_PATH" ]; then
    echo "INSTALLER_PATH не указан в .env. Укажите путь к установочному файлу."
    exit 1
fi

# Проверяем наличие установочного файла
if [ -f "$INSTALLER_PATH" ]; then
    echo "Установочный файл найден: $INSTALLER_PATH"
    unzip "$INSTALLER_PATH" -d /opt/1c/
    chmod +x /opt/1c/setup-full-*.run
    /opt/1c/setup-full-*.run
else
    echo "Установочный файл не найден: $INSTALLER_PATH"
    exit 1
fi

# Настройка монтирования WebDAV
echo "https://webdav.yandex.ru /mnt/yandexDisk davfs user,rw 0 0" >> /etc/fstab
echo "https://webdav.cloud.mail.ru /mnt/mailRuDisk davfs user,rw 0 0" >> /etc/fstab

# Монтирование с учетом данных из .env
echo "$YANDEX_LOGIN $YANDEX_PASSWORD" > /etc/davfs2/secrets
echo "$MAILRU_LOGIN $MAILRU_PASSWORD" >> /etc/davfs2/secrets
chmod 600 /etc/davfs2/secrets

# Монтируем диски
mount -a
