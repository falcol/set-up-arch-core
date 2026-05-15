#!/usr/bin/sh
BASE_DIR=$PWD

sudo apt update
sudo apt install vim git curl unzip firefox thunderbird openvpn tmux fzf -y
sudo apt -y install dirmngr apt-transport-https lsb-release ca-certificates

# Improve Laptop Battery: only for laptop
# sudo apt install tlp tlp-rdw

# install chrome
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# sudo dpkg -i google-chrome-stable_current_amd64.deb
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
# sudo apt install ./google-chrome-stable_current_amd64.deb -y && \
# rm google-chrome-stable_current_amd64.deb && \
# wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null && \
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
sudo apt install ./google-chrome-stable_current_amd64.deb -y && \
rm google-chrome-stable_current_amd64.deb && \

# 2. Tạo Keyring bảo mật chuẩn
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null && \

# 3. Ghi đè cấu hình chuẩn và cập nhật lại danh sách gói
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list && \
sudo apt update

# Install ibus-bamboo
# sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo -y
# sudo apt-get update
# sudo apt-get install ibus-bamboo -y
# ibus restart
# env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"

# install baboo
sudo apt update
sudo apt install fcitx5 fcitx5-bamboo fcitx5-config-qt -y
im-config -n fcitx5
printf "\n# Fcitx5 Configuration\nexport GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=@im=fcitx\nexport SDL_IM_MODULE=fcitx\nexport GLFW_IM_MODULE=ibus\n" >> ~/.zshrc && source ~/.zshrc

# Install telegram
# sudo apt install telegram-desktop
sudo apt install snapd
# sudo snap install telegram-desktop
#!/bin/bash

# --- Cấu hình ---
APP_NAME="telegram-desktop"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
BIN_LINK="/usr/local/bin/tele"
TMP_DIR="/tmp/telegram_install"

# Link tải chính thức từ Telegram.org (Tự động nhận diện bản mới nhất)
DOWNLOAD_URL="https://telegram.org/dl/desktop/linux"

echo "🚀 Bắt đầu tối ưu và cài đặt Telegram Binary (V2)..."

# 1. Xóa bản Snap nếu có
if snap list | grep -q "$APP_NAME"; then
    echo "📦 Đang gỡ bỏ bản Snap..."
    sudo snap remove $APP_NAME
fi

# 2. Dọn dẹp và tạo thư mục
echo "🧹 Đang dọn dẹp..."
rm -rf "$INSTALL_DIR"
rm -rf "$TMP_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$TMP_DIR"

# 3. Tải bản mới nhất (Sử dụng -L để đi theo đường dẫn chuyển hướng)
echo "📥 Đang tải Telegram từ telegram.org..."
if ! wget -L -O "$TMP_DIR/telegram.tar.xz" "$DOWNLOAD_URL"; then
    echo "❌ Lỗi: Không thể tải xuống file. Vui lòng kiểm tra kết nối mạng!"
    exit 1
fi

# 4. Giải nén
echo "📂 Đang giải nén..."
if ! tar -xvf "$TMP_DIR/telegram.tar.xz" -C "$TMP_DIR"; then
    echo "❌ Lỗi: Giải nén thất bại!"
    exit 1
fi

# 5. Cài đặt vào hệ thống
echo "🏠 Đang đưa Telegram vào 'nhà mới'..."
# Lưu ý: Giải nén ra thường có thư mục tên là 'Telegram' bên trong
mv "$TMP_DIR/Telegram"/* "$INSTALL_DIR/"

# 6. Tạo lệnh gõ nhanh 'tele'
echo "🔗 Tạo liên kết hệ thống..."
sudo ln -sf "$INSTALL_DIR/Telegram" "$BIN_LINK"

# 7. Dọn dẹp file tạm
rm -rf "$TMP_DIR"

echo "✅ ĐÃ XONG!"
echo "--------------------------------------------------"
echo "👉 Gõ 'tele' để mở hoặc tìm trong Menu ứng dụng."
echo "--------------------------------------------------"

# Chạy lần đầu
"$INSTALL_DIR/Telegram" &

# Install flatpak https://flatpak.org/setup/Ubuntu
# flatpak install flathub org.telegram.desktop

## NODEJS
curl -sL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y

# Install dash to dock
sudo apt install gnome-tweaks gnome-shell-extensions gettext -y
# Click đóng mở
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
gsettings set org.gnome.mutter center-new-windows true

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
sudo apt install zsh-autosuggestions zsh-syntax-highlighting zsh fzf -y
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
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Thiết lập theme Powerlevel10k
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# Cấu hình plugin: Loại bỏ zsh-syntax-highlighting để tránh xung đột với fast-syntax-highlighting
# Thứ tự: zsh-autocomplete nên đứng đầu hoặc cuối tùy sở thích, ở đây tôi để cuối để ổn định.
sed -i 's/plugins=(.*)/plugins=(git fzf zsh-autosuggestions zsh-history-substring-search fast-syntax-highlighting)/g' ~/.zshrc 
echo '
# Cấu hình phím mũi tên cho history-substring-search
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
' >> ~/.zshrc
rm -f ~/.zcompdump* 
source ~/.zshrc
sudo chsh -s $(which zsh) $(whoami)

# -------------------------
# 1. Cập nhật hệ thống và cài đặt các phụ kiện cần thiết
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 2. Thêm GPG key chính thức của Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Thiết lập Repository cho Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Cài đặt Docker Engine, CLI, Containerd và Docker Compose Plugin (V2)
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Cấp quyền cho User hiện tại (Để chạy docker không cần sudo)
sudo usermod -aG docker $USER

# 6. Thông báo hoàn tất
echo "----------------------------------------------------"
echo "Cài đặt hoàn tất! Docker version:"
docker --version
echo "Docker Compose version:"
docker compose version
echo "----------------------------------------------------"
echo "LƯU Ý: Hãy ĐĂNG XUẤT và ĐĂNG NHẬP LẠI để quyền Docker có hiệu lực."

