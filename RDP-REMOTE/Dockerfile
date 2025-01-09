# Задаем аргумент TAG для версии образа
ARG TAG=latest

# Строим базовый образ с необходимыми зависимостями
FROM ubuntu:$TAG AS builder


# Установим аргументы для имени пользователя и пароля
ARG USERNAME_RDP
ARG PASSWORD_RDP

# Устанавливаем их как переменные окружения
ENV USERNAME_RDP=${USERNAME_RDP}
ENV PASSWORD_RDP=${PASSWORD_RDP}


# Убедитесь, что в контейнере установлен нужный пользователь
# Создаем пользователя и группу usr1cv8, если они не существуют


# Изменяем владельца каталога на группу www-data
RUN mkdir -p /mnt/yandexDisk  
RUN chown -R www-data:www-data /mnt/yandexDisk


RUN sed -i -E 's/^# deb-src /deb-src /g' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        build-essential \
        dpkg-dev \
        git \
        libpulse-dev \
        davfs2 \
    && rm -rf /var/lib/apt/lists/*

# Строим финальный образ
FROM ubuntu:$TAG

# Устанавливаем зависимости для финального образа
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        firefox \
        git \
        locales \
        pavucontrol \
        sudo \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme \
        davfs2 \
    && rm -rf /var/lib/apt/lists/*

# Настройки PulseAudio
RUN sed -i -E 's/^; autospawn =.*/autospawn = yes/' /etc/pulse/client.conf \
    && [ -f /etc/pulse/client.conf.d/00-disable-autospawn.conf ] && sed -i -E 's/^(autospawn=.*)/# \1/' /etc/pulse/client.conf.d/00-disable-autospawn.conf || : \
    && locale-gen en_US.UTF-8

# Устанавливаем локаль
ENV LANG=en_US.UTF-8

# Копируем необходимые файлы из промежуточного образа
COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/

# Копируем entrypoint и webdav_mount.sh
COPY entrypoint.sh /usr/bin/entrypoint
COPY webdav_mount.sh /usr/bin/webdav_mount

# Делаем webdav_mount.sh исполнимым
RUN chmod +x /usr/bin/webdav_mount


# Открываем порты
EXPOSE 3389/tcp

# Устанавливаем основной entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
