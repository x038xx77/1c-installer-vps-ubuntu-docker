FROM ubuntu:20.04

# Устанавливаем зависимости
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
    && apt-get clean

# Создаем рабочую директорию
WORKDIR /opt/1c

# Указываем точку монтирования для установочных файлов
VOLUME /installer

# Добавляем скрипт установки
COPY install.sh /opt/1c/install.sh
RUN chmod +x /opt/1c/install.sh

# Настройка Apache2
RUN a2enmod dav dav_fs
RUN sed -i 's/80/5343/' /etc/apache2/ports.conf
RUN sed -i 's/Listen 80/Listen 5343/' /etc/apache2/ports.conf

# Создаем точки монтирования
RUN mkdir -p /mnt/yandexDisk /mnt/mailRuDisk

# Команда запуска
CMD ["/bin/bash"]
