#!/bin/bash

# Проверка наличия необходимых переменных
if [ -z "$WEBDAV_URL_YANDEX" ] || [ -z "$YANDEX_LOGIN" ] || [ -z "$YANDEX_PASSWORD" ]; then
    echo "Ошибка: Не заданы все необходимые переменные для WebDAV в .env"
    exit 1
fi

# Создаем директорию для монтирования, если ее нет
mkdir -p /mnt/yandexDisk

# Пытаемся смонтировать WebDAV
sudo mount -t davfs ${WEBDAV_URL_YANDEX} /mnt/yandexDisk -o uid=1000,gid=1000,username=${YANDEX_LOGIN},password=${YANDEX_PASSWORD}

# Проверяем успешность монтирования
if [ $? -eq 0 ]; then
    echo "WebDAV успешно смонтирован в /mnt/yandexDisk"
else
    echo "Ошибка при монтировании WebDAV"
    exit 1
fi
