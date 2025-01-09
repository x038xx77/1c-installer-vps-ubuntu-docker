#!/usr/bin/env bash
# Меняем владельца папки на usr1cv8
chown -R usr1cv8:usr1cv8 /mnt/yandexDisk

# Запускаем основной процесс
exec "$@"
# Загружаем переменные из .env
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Создаем группу и пользователя
groupadd --gid 1020 "$USERNAME_RDP"
useradd --shell /bin/bash --uid 1020 --gid 1020 --password "$(openssl passwd -1 "$PASSWORD_RDP")" --create-home --home-dir "/home/$USERNAME_RDP" "$USERNAME_RDP"
usermod -aG sudo "$USERNAME_RDP"

# Создаем папку для монтирования
mkdir -p /mnt/yandexDisk  # Создаем папку, если её нет

# Устанавливаем права на папку для пользователя
chown -R "$USERNAME_RDP":"$USERNAME_RDP" /mnt/yandexDisk  # Даем полные права на папку пользователю
find /mnt/yandexDisk -type f ! -name 'lost+found' -exec sudo chown -R usr1cv8:www-data {} \;

# Запускаем xrdp sesman
/usr/sbin/xrdp-sesman

# Запускаем xrdp в foreground, если команды не указаны
if [ -z "$1" ]; then
    /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi
