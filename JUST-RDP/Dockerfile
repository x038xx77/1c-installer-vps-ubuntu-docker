# Используем базовый образ Ubuntu 20.04
FROM ubuntu:20.04

# Создаем рабочую директорию для логов и других файлов
RUN mkdir -p /opt/1c

# Устанавливаем локаль для поддержки кириллицы
RUN apt-get update && apt-get install -y locales \
    && locale-gen ru_RU.UTF-8 \
    && update-locale LANG=ru_RU.UTF-8 \
    && echo "Locale set to Russian" | tee -a /opt/1c/installation_log.txt

# Настроим систему для автоматического принятия соглашений
RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
RUN echo ttf-mscorefonts-installer msttcorefonts/eula select true | debconf-set-selections

# Устанавливаем необходимые зависимости
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libx11-dev \
    libxext-dev \
    libssl1.1 \
    libfreetype6 \
    libfontconfig1 \
    libxrender1 \
    apache2 \
    davfs2 \
    procps \
    tzdata \
    debconf-utils \
    curl \
    fontconfig \
    unixodbc \
    ttf-mscorefonts-installer \
    libgsf-1-114 \
    keyboard-configuration \
    geoclue-2.0 \
    gstreamer1.0-plugins-bad \
    && apt-get clean \
    && echo "Dependencies installed successfully" | tee -a /opt/1c/installation_log.txt

# Настроим временную зону и раскладку клавиатуры 
RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo "Timezone set to Europe/Moscow" | tee -a /opt/1c/installation_log.txt

RUN dpkg-reconfigure -f noninteractive keyboard-configuration \
    && echo "Keyboard layout reconfigured" | tee -a /opt/1c/installation_log.txt

# Создаем рабочую директорию для установки 1С
WORKDIR /opt/1c

# Указываем аргументы для передачи переменных
ARG YANDEX_LOGIN
ARG YANDEX_PASSWORD
ARG MAILRU_LOGIN
ARG MAILRU_PASSWORD

# Создаем точки монтирования внутри контейнера
RUN mkdir -p /mnt/yandexDisk /mnt/mailRuDisk

# Копируем скрипт монтирования WebDAV
COPY install-webdav.sh /usr/local/bin/install-webdav.sh
RUN chmod +x /usr/local/bin/install-webdav.sh

# Настраиваем переменные окружения для логинов и паролей
ENV YANDEX_LOGIN=${YANDEX_LOGIN}
ENV YANDEX_PASSWORD=${YANDEX_PASSWORD}
ENV MAILRU_LOGIN=${MAILRU_LOGIN}
ENV MAILRU_PASSWORD=${MAILRU_PASSWORD}

# Запускаем скрипт монтирования WebDAV
#RUN /usr/local/bin/install-webdav.sh

# Устанавливаем переменные окружения для 1С
ARG ONEC_VERSION
ENV ONEC_VERSION=${ONEC_VERSION}

# Указываем путь установки 1С
ARG INSTALLER_PATH
ENV INSTALLER_PATH=${INSTALLER_PATH}

# Копируем установочный файл 1С
COPY ${INSTALLER_PATH} /opt/1c/installer.zip

# Распаковываем архив
RUN unzip /opt/1c/installer.zip -d /opt/1c/ && rm /opt/1c/installer.zip

# Выполняем установку 1С
RUN /opt/1c/setup-full-${ONEC_VERSION}-x86_64.run

# Добавляем скрипт настройки VNC
COPY setup_vnc.sh /usr/local/bin/setup_vnc.sh
RUN chmod +x /usr/local/bin/setup_vnc.sh

# Установка переменной окружения для пароля VNC
ARG PAS_SETUP_VNS
ENV PAS_SETUP_VNS=${PAS_SETUP_VNS}

# Настроим пользователя и VNC, используя скрипт
RUN /usr/local/bin/setup_vnc.sh

# Открываем порты для VNC и RDP
EXPOSE 5901 3389

# Команда по умолчанию
CMD ["apachectl", "-D", "FOREGROUND"]
