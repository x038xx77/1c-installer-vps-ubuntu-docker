#!/bin/bash

set -e  # Прерывать выполнение при ошибке

echo "Настроим монтирование WebDAV..."

# Добавляем записи в /etc/fstab для монтирования WebDAV
echo "https://webdav.yandex.ru /mnt/yandexDisk davfs user,rw 0 0" >> /etc/fstab
echo "https://webdav.cloud.mail.ru /mnt/mailRuDisk davfs user,rw 0 0" >> /etc/fstab

# Создаем файл с паролями для davfs
cat <<EOL > /etc/davfs2/secrets
https://webdav.yandex.ru $YANDEX_LOGIN $YANDEX_PASSWORD
https://webdav.cloud.mail.ru $MAILRU_LOGIN $MAILRU_PASSWORD
EOL
chmod 600 /etc/davfs2/secrets

# Создаем директории для монтирования, если они еще не существуют
mkdir -p /mnt/yandexDisk /mnt/mailRuDisk

# Монтируем диски
mount -a

# Проверяем, что диски смонтированы
if mountpoint -q /mnt/yandexDisk && mountpoint -q /mnt/mailRuDisk; then
  echo "WebDAV-диски успешно смонтированы."
else
  echo "Ошибка монтирования WebDAV-дисков!" >&2
  exit 1
fi

echo "Установка завершена."
