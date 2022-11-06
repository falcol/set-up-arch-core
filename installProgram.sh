#!/bin/bash
echo "first"
sudo pacman-mirrors --fasttrack
sudo pacman -Syyu
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer
sudo pacman -S ufw
sudo pacman -S gufw
sudo ufw enable
sudo systemctl enable ufw

echo "install program"
sudo pacman -S telegram-desktop
sudo pacman -S kitty
sudo pamac build mongodb-bin
sudo pamac build mongodb-compass-beta-bin
sudo pacman -S redis
sudo pacman -S docker
sudo pacman -S docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker.service
sudo pacman -S gnome-keyring

mkdir setUp

echo "Vimplug Install"
cd setUp
git clone https://github.com/falcol/vim-plug-install.git
cd vim-plug-install
chmod u+x install-vimplug-scripts.sh
./install-vimplug-scripts.sh
cd
sudo pacman -S nodejs npm

echo "chrome"

sudo pamac install google-chrome
cd

echo "vscode"
sudo pamac install visual-studio-code-bin
cd

echo "ZSH"
sudo pacman -Syu zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "wps"
cd
sudo pamac install wps-office
makepkg -si
cd

echo "font MS"
sudo pamac install ttf-ms-fonts
sudo pamac install ttf-fira-code
cd

echo "ibus"
sudo pamac install ibus
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

