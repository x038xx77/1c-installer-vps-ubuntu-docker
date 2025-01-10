# 1c-installer-vps-ubuntu
VPS#
генерация пароля 
openssl passwd -6

создаем пользователя и добавляем сразу в группу www-data 

sudo useradd --shell /bin/bash --create-home --uid 1020 --gid www-data --password '$6$i1AoXUe2q0USZHaj$RNuOuxxjOwXz1ZkmmD9MSMRfm9dp8JM.pNGZPbYX/4Q4be9e.iYH/W.djfKVH8PqsnX9sjIjk.23A/iIQ1V8U1' usr1cv8


sudo usermod -aG sudo usr1cv8


id usr1cv8 получаем uid=1002(usr1cv8) gid=1004(usr1cv8) groups=1004(usr1cv8)

chmod +x entrypoint.sh
HOSTNAME=$(hostname) sudo docker compose up --build


ВОЗМОЖНО нужно запускать от пользователя
sudo su usr1cv8
### sudo docker compose up --build


RDP
Создайте файл скрипта:
Откройте терминал и создайте новый файл, например, setup_vnc.sh:
nano setup_vnc.sh


​
Вставьте следующий код в файл:
#!/bin/bash

# Установка XFCE и VNC-сервера
sudo apt update
sudo apt install -y xfce4 xfce4-goodies
sudo apt install -y tightvncserver autocutsel

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

​
Сохраните файл: Нажмите CTRL + X, затем Y, и нажмите Enter, чтобы сохранить изменения.
Сделайте скрипт исполняемым:
chmod +x setup_vnc.sh


​
Запустите скрипт:
./setup_vnc.sh

