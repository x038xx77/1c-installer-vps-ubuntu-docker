# Используем базовый образ Ubuntu 20.04
FROM ubuntu:20.04

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
    && echo "Dependencies installed successfully"

# Создаем рабочую директорию для установки 1С
WORKDIR /opt/1c

# Создаем директорию для логов
RUN mkdir -p /opt/1c

# Указываем точку монтирования для установочных файлов
VOLUME /installer

# Копируем скрипт установки в контейнер и даем ему права на исполнение
COPY install.sh /opt/1c/install.sh
RUN chmod +x /opt/1c/install.sh

# Настроим Apache2 для работы с WebDAV
RUN a2enmod dav dav_fs            # Включаем модули DAV для Apache
RUN sed -i 's/80/5343/' /etc/apache2/ports.conf  # Меняем порт на 5343
RUN sed -i 's/Listen 80/Listen 5343/' /etc/apache2/ports.conf # Настройка прослушивания порта 5343

# Создаем директории для монтирования WebDAV
RUN mkdir -p /mnt/yandexDisk /mnt/mailRuDisk

# Устанавливаем первый пакет зависимостей с выводом в лог
RUN apt-get update && apt-get install -yq procps tzdata debconf-utils curl fontconfig unixodbc ttf-mscorefonts-installer libgsf-1-114 keyboard-configuration \
    && echo "First batch of dependencies installed successfully" | tee -a /opt/1c/installation_log.txt

# Настроим временную зону и раскладку клавиатуры без использования файла selections.conf
RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo "Timezone set to Europe/Moscow" | tee -a /opt/1c/installation_log.txt

RUN dpkg-reconfigure -f noninteractive keyboard-configuration \
    && echo "Keyboard layout reconfigured" | tee -a /opt/1c/installation_log.txt

# Устанавливаем оставшиеся зависимости с выводом в лог
RUN apt-get install -yq geoclue-2.0 gstreamer1.0-plugins-bad \
    && echo "Remaining dependencies installed successfully" | tee -a /opt/1c/installation_log.txt

# Правим локаль на русскую
RUN export LANG=ru_RU.UTF-8 \
    && echo "Locale set to Russian" | tee -a /opt/1c/installation_log.txt

# Команда, которая будет выполнена при запуске контейнера
CMD ["/bin/bash"]
