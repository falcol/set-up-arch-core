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
# sudo pacman -S kitty
# sudo pamac build mongodb-bin
# sudo pamac build mongodb-compass-beta-bin
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

sudo pamac build google-chrome
sudo pamac build coccoc-browser-stable

cd

echo "vscode"
sudo pamac build visual-studio-code-bin
pamac build cursor-bin
pamac build antigravity

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
sudo pamac build ttf-ms-fonts
sudo pamac build ttf-fira-code
sudo pacman -S ttf-jetbrains-mono
cd

echo "ibus"
sudo pamac install ibus
pamac build ibus-bamboo
sudo nano /etc/environment
# export GTK_IM_MODULE=xim  # hoặc ibus
# export QT_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus
# export QT4_IM_MODULE=ibus
# export CLUTTER_IM_MODULE=ibus
# export GLFW_IM_MODULE=ibus

# ibus-daemon -drx
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

