#!/bin/bash

# Установка XFCE и VNC-сервера
sudo apt update
sudo apt install -y xfce4 xfce4-goodies
sudo apt install -y tightvncserver autocutsel
sudo apt install -y firefox

# Добавление нового пользователя
USERNAME="usr1cv8"
sudo useradd -m -s /bin/bash $USERNAME
sudo usermod -aG sudo $USERNAME
echo "Установите пароль для пользователя $USERNAME:"
sudo passwd $USERNAME

# Настройка VNC для нового пользователя
sudo -u $USERNAME vncpasswd

# Создание xstartup файла
sudo -u $USERNAME bash -c 'cat <<EOF > ~/.vnc/xstartup
#!/bin/bash
xrdb \$HOME/.Xresources
autocutsel -fork
startxfce4 &
EOF'

sudo chmod 755 /home/$USERNAME/.vnc/xstartup

# Настройка автозапуска VNC-сервера
sudo bash -c "cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start VNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/home/$USERNAME

PIDFile=/home/$USERNAME/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF"

# Включение и запуск VNC-сервера
sudo systemctl enable vncserver@1
sudo systemctl start vncserver@1

# Установка RDP (опционально)
echo "Хотите установить xrdp? (y/n)"
read INSTALL_XRDP
if [ "$INSTALL_XRDP" == "y" ]; then
    sudo apt install -y xrdp
    sudo sed -i 's/new_cursors=true/new_cursors=false/' /etc/xrdp/xrdp.ini

    # Настройка .xsession для пользователя
    sudo -u $USERNAME bash -c 'cat <<EOF > ~/.xsession
xfce4-session
export XDG_SESSION_DESKTOP=xubuntu
export XDG_DATA_DIRS=/usr/share/xfce4:/usr/local/share:/usr/share:/var/lib/snapd/usr1cv8devart:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg/xfce4:/etc/xdg:/etc/xdg
EOF'

    # Включение и перезапуск xrdp
    sudo systemctl enable xrdp
    sudo systemctl restart xrdp
fi

echo "Настройка завершена."
