#!/bin/bash

# Загрузка переменных из .env
echo "Загружаю переменные из .env..."
source /env/.env  # Подключение переменных из .env

# Установка переменных
ONEC_RELEASE=$(echo $ONEC_VERSION | cut -d . -f 3)
nls_install="ru"  # Устанавливаем русский язык по умолчанию

echo "Текущая версия 1С: $ONEC_VERSION"
echo "Release: $ONEC_RELEASE"

# Проверка пути до установочного файла
echo "Проверяю наличие установочного файла..."
if [ -f "$INSTALLER_PATH" ]; then
    echo "Установочный файл найден: $INSTALLER_PATH"
    unzip "$INSTALLER_PATH" -d /opt/1c/
else
    echo "Установочный файл не найден: $INSTALLER_PATH"
    exit 1
fi

# Установка 1С для версии >= 20
echo "Установка 1С версии >= 20..."
    
# Выбор языков для установки
if [ "$nls_install" = "true" ]; then 
    nls_install="az,ar,hy,bg,hu,el,vi,ka,kk,zh,it,es,lv,lt,de,pl,ro,ru,tr,tk,fr,uk"
else
    nls_install="ru"
fi

case "$INSTALLER_TYPE" in
    server)
        echo "Установка сервера (для версии >= 20)..."
        ./setup-full-${ONEC_VERSION}-x86_64.run --mode unattended --enable-components server,ws,$nls_install
        ;;
    server-crs)
        echo "Установка сервера с CRS (для версии >= 20)..."
        ./setup-full-${ONEC_VERSION}-x86_64.run --mode unattended --enable-components server,ws,config_storage_server,$nls_install
        ;;    
    client)
        echo "Установка клиента (для версии >= 20)..."
        ./setup-full-${ONEC_VERSION}-x86_64.run --mode unattended --enable-components server,client_full,$nls_install
        ;;
    thin-client)
        echo "Установка тонкого клиента (для версии >= 20)..."
        ./setup-thin-${ONEC_VERSION}-x86_64.run --mode unattended --enable-components ru
        ;;
    *)
        echo "Неизвестный тип установки: $INSTALLER_TYPE"
        exit 1
        ;;
esac

# Настройка монтирования WebDAV
echo "Настрою монтирование WebDAV..."

echo "https://webdav.yandex.ru /mnt/yandexDisk davfs user,rw 0 0" >> /etc/fstab
echo "https://webdav.cloud.mail.ru /mnt/mailRuDisk davfs user,rw 0 0" >> /etc/fstab

# Монтирование с учетом данных из .env
source /env/.env
echo "$YANDEX_LOGIN $YANDEX_PASSWORD" > /etc/davfs2/secrets
echo "$MAILRU_LOGIN $MAILRU_PASSWORD" >> /etc/davfs2/secrets
chmod 600 /etc/davfs2/secrets

# Монтируем диски
mount -a

echo "Установка завершена."
