#!/usr/bin/sh
BASE_DIR=$PWD

sudo apt update
sudo apt install vim git curl unzip firefox thunderbird openvpn tmux fzf -y
sudo apt -y install dirmngr apt-transport-https lsb-release ca-certificates

# Improve Laptop Battery:
sudo apt install tlp tlp-rdw

# install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Install ibus-bamboo
sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo -y
sudo apt-get update
sudo apt-get install ibus-bamboo -y
ibus restart
env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"

# Install telegram
# sudo apt install telegram-desktop
# sudo apt install snapd
# sudo snap install telegram-desktop

# Install flatpak https://flatpak.org/setup/Ubuntu
flatpak install flathub org.telegram.desktop

## NODEJS
curl -sL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y

# Install dash to dock
sudo apt install gnome-tweaks gnome-shell-extensions gettext -y

## FONTS
mkdir -p ~/.local/share/fonts
cp $BASE_DIR/fonts/*.ttf ~/.local/share/fonts/.
fc-cache -f -v

## VSCODE
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code

## COPY DOTFILES
cp -a $BASE_DIR/dotfiles/. ~/.
xrdb -merge ~/.Xresources

echo 'export PATH="~/.local/bin:$PATH"' >> ~/.bashrc
echo "source /usr/share/doc/fzf/examples/key-bindings.bash" >> ~/.bashrc
echo "source /usr/share/doc/fzf/examples/completion.bash" >> ~/.bashrc
. ~/.bashrc

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vim plugins
vim +PlugInstall +qall

# install ohmyzsh
cd
sudo apt install zsh-autosuggestions zsh-syntax-highlighting zsh -y
# Set the default shell to zsh
sudo chsh -s $(which zsh) $(whoami)
# Install oh-my-zsh: https://ohmyz.sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Install Powerlevel10k: https://github.com/romkatv/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
