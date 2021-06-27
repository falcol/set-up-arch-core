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
sudo pacman -S neofetch 

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
sudo pacman -S --needed base-devel git
cd setUp
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si
cd
yay -S google-chrome
cd

echo "vscode"
cd setUp
git clone https://aur.archlinux.org/visual-studio-code-bin.git
cd visual-studio-code-bin/
makepkg -si
cd

echo "ZSH"
sudo pacman -Syu zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "wps"
cd
cd setUp
git clone https://aur.archlinux.org/wps-office.git
cd wps-office
makepkg -si
cd

echo "font MS"
cd setUp
git clone https://aur.archlinux.org/ttf-ms-fonts.git
cd ttf-ms-fonts
makepkg -si
cd

echo "ibus"
sudo pamac install ibus
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

