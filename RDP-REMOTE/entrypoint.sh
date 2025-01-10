#!/usr/bin/env bash
echo "Инициализация RDP-окружения..."

# Загружаем переменные из .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Проверка переменных окружения
if [ -z "$USERNAME_RDP" ] || [ -z "$PASSWORD_RDP" ]; then
    echo "ERROR: Переменные USERNAME_RDP и PASSWORD_RDP должны быть определены в .env"
    exit 1
fi

# Отключаем SSL, если переменная SSL_SECURITY_LAYER установлена в false
if [ "$SSL_SECURITY_LAYER" == "false" ]; then
    echo "Отключение SSL-соединений..."
    # Здесь можно добавить логику для отключения SSL, например:
    # Для XRDP можно изменить конфигурацию, чтобы не использовать SSL
    # Например, закомментировать или изменить строки, связанные с SSL в конфигурации XRDP
fi

# Создаём пользователя и группу, если они отсутствуют
if ! id "$USERNAME_RDP" &>/dev/null; then
    echo "Создание пользователя $USERNAME_RDP..."
    useradd --shell /bin/bash --create-home --home-dir "/home/$USERNAME_RDP" \
        --password "$(openssl passwd -1 "$PASSWORD_RDP")" "$USERNAME_RDP"
fi

# Проверяем, существует ли пользователь
if ! id "usr1cv8" &>/dev/null; then
    echo "Пользователь usr1cv8 не существует."
    
else
    echo "Пользователь usr1cv8 существует. Обновляем пароль..."
    # Обновляем пароль с хешированием
    usermod -aG sudo usr1cv8
    sudo find /mnt/yandexDisk -type f ! -name 'lost+found' -exec sudo chown -R usr1cv8:www-data {} \;
    echo "usr1cv8:$(openssl passwd -1 "$PASSWORD_RDP")" | chpasswd -e
fi


if ! getent group xrdp &>/dev/null; then
    echo "Группа xrdp отсутствует, создаём..."
    groupadd xrdp
fi

# Назначаем пользователя в нужные группы
usermod -aG sudo,www-data,xrdp "$USERNAME_RDP"

# Убедимся, что у пользователя есть необходимые права
chown -R "$USERNAME_RDP":xrdp "/home/$USERNAME_RDP"

# Создаём папку для монтирования (если она отсутствует)
if [ ! -d "$MOUNT_DIR_YANDEX" ]; then
    echo "Создаём папку $MOUNT_DIR_YANDEX..."
    mkdir -p "$MOUNT_DIR_YANDEX"
fi

# Устанавливаем права на папку
chown -R "$USERNAME_RDP":www-data "$MOUNT_DIR_YANDEX" || true

# Запускаем xrdp sesman
echo "Запуск xrdp sesman..."
/usr/sbin/xrdp-sesman &

# Убедимся, что xrdp-сессии работают
if ! pgrep -x "xrdp-sesman" &>/dev/null; then
    echo "Ошибка: xrdp-sesman не запустился."
    exit 1
fi

# Запускаем xrdp
echo "Запуск xrdp..."
sudo usermod -aG sudo,www-data,xrdp $USERNAME_RDP
/usr/sbin/xrdp --nodaemon &
if ! pgrep -x "xrdp" &>/dev/null; then
    echo "Ошибка: xrdp не запустился."
    exit 1
fi
echo "Настройка XRDP..."

# Отключаем new_cursors в конфигурации XRDP
sudo sed -i 's/new_cursors=true/new_cursors=false/' /etc/xrdp/xrdp.ini

# Настройка .xsession для пользователя
sudo -u $USERNAME_RDP bash -c 'cat <<EOF > /home/$USERNAME_RDP/.xsession
xfce4-session
export XDG_SESSION_DESKTOP=xubuntu
export XDG_DATA_DIRS=/usr/share/xfce4:/usr/local/share:/usr/share:/var/lib/snapd/:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg/xfce4:/etc/xdg:/etc/xdg
EOF'

# Включение и перезапуск xrdp
sudo systemctl enable xrdp
sudo systemctl restart xrdp


# Проверяем статус Apache2
if ! pgrep -x "apache2" &>/dev/null; then
    echo "Apache2 не запущен, запускаем..."
    service apache2 start
fi

# Перезапускаем Apache после публикации
echo "Публикация 1C..."
sudo usermod -aG davfs2 usr1cv8
sudo usermod -aG www-data usr1cv8
sudo /opt/1cv8/x86_64/8.3.25.1445/webinst -publish -apache24 -wsdir InfoBase2 -dir /mnt/yandexDisk/1C-BASES/base -connstr "File=/mnt/yandexDisk/1C-BASES/base;" -confpath /etc/apache2/apache2.conf
sudo chmod -R 755 "$MOUNT_DIR_YANDEX"/lost+found 2>/dev/null || true

echo "Перезапуск Apache2..."
service apache2 restart

# Проверяем конечный статус Apache
if ! pgrep -x "apache2" &>/dev/null; then
    echo "Ошибка: Apache2 не удалось перезапустить."
    exit 1
fi

# Ожидаем, чтобы контейнер не завершился сразу
echo "Контейнер работает, сервисы запущены."
tail -f /dev/null
