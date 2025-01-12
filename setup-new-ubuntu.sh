#!/bin/bash

# Обновление списка пакетов и установка curl
sudo apt update && sudo apt install -y curl

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Node.js через NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# Перезагрузка оболочки для применения изменений и загрузки NVM
# Добавляем в bashrc загрузку NVM для текущей сессии
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Применение изменений в текущей сессии
source ~/.bashrc

# Установка Node.js версии 18.17.0 через NVM
nvm install 18.17.0

# Установка pnpm через npm
npm install -g pnpm

echo "Установка завершена."

# chmod +x setup-new-ubuntu.sh