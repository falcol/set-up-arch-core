````markdown
# 🐧 Linux Installation & Setup Notes (Ubuntu / Manjaro / Garuda)

> Tổng hợp hướng dẫn cài đặt và thiết lập môi trường làm việc trên các distro phổ biến: **Ubuntu**, **Manjaro**, **Garuda Linux**.
> Bao gồm cài đặt phần mềm, quản lý gói, thiết lập theme, input method, Docker, database, font, terminal, shell và các công cụ dev khác.

---

## 🚀 Tạo USB cài đặt Linux

### 1. Tạo USB Ubuntu / Garuda / Manjaro
```bash
# Burn ISO Ubuntu:
sudo dd bs=4M if=/path/to/file.iso of=/dev/sdX status=progress oflag=sync

# Kiểm tra USB:
sudo fdisk -l
````

> 💡 Đảm bảo `of=/dev/sdX` đúng với USB (KHÔNG có số phân vùng như `/dev/sdb1`)
---

Dưới đây là **cấu hình phân vùng Ubuntu mới nhất (chuẩn UEFI)** đã được thêm vào bản `README.md`.

---

## 🐧 Cài đặt Ubuntu

#### Phân vùng thủ công (recommended for advanced users)

| Dung lượng | Hệ thống tập tin  | Cờ (Flags) | Mount Point |
| ---------- | ----------------- | ---------- | ----------- |
| 512MB      | FAT32             | boot, esp  | /boot/efi   |
| 16GB       | linuxswap         | swap       | (None)      |
| 30GB+      | ext4 (hoặc btrfs) |            | `/`         |
| tùy chọn   | ext4              |            | `/home`     |

> 💡 **không cần phân vùng BIOS/GRUB** nếu dùng UEFI. Ubuntu installer sẽ tạo ESP và GRUB loader nếu chưa có.

---

**Có thể thay thế ext4 bằng btrfs nếu cần snapshot với Timeshift (nếu dùng bản Ubuntu-based hỗ trợ)**

---

### 💡 Mẹo:

* Nếu cài **dual boot với Windows**, **KHÔNG xoá ESP cũ** (EFI System Partition), chỉ mount nó vào `/boot/efi` và không format.
* Nếu ổ đĩa đã dùng GPT/UEFI, không cần thêm `BIOS boot` partition.

---

## 🦅 Cài đặt Garuda Linux

### Phân vùng gợi ý:

| Dung lượng | Hệ thống tập tin | Flags | Mount Point |
| ---------- | ---------------- | ----- | ----------- |
| 512MB      | FAT32            | boot  | /boot/efi   |
| 16GB       | linuxswap        | swap  | (None)      |
| còn lại    | Btrfs            |       | /           |

🔗 Tham khảo thêm: [https://www.hacknos.com/garuda-linux-installation/](https://www.hacknos.com/garuda-linux-installation/)

---

## 🐉 Cài đặt Manjaro Linux

### Phân vùng gợi ý:

| Dung lượng | Hệ thống tập tin | Flags | Mount Point |
| ---------- | ---------------- | ----- | ----------- |
| 512MB      | FAT32            | boot  | /boot/efi   |
| 16GB       | linuxswap        | swap  | (None)      |
| 25GB       | ext4             |       | /           |
| 30GB       | ext4             |       | /home       |

---

## 🌐 Thay đổi mirror tốc độ cao

### Manjaro:

```bash
sudo pacman-mirrors -s --country Japan,Singapore,Hong_Kong,South_Korea,Germany,Netherlands
sudo pacman -Syy
```

### Garuda:

```bash
sudo reflector --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist
sudo pacman -Syu
```

---

## 🔧 Cài đặt file `.sh`

```bash
chmod u+x name.sh
./name.sh
```

---

## 🧩 Cài đặt Gnome Extensions
🔗 [customize-gnome](https://github.com/1amSimp1e/dots?tab=readme-ov-file#gnome)

### 1. Truy cập website chính:

🔗 [https://extensions.gnome.org/](https://extensions.gnome.org/)

### 2. Cài tiện ích:

```bash
sudo apt install chrome-gnome-shell gnome-shell-extension-prefs gnome-tweaks gnome-shell-extensions
```

### 3. Gnome Tweaks:

```bash
# Mở Tweaks:
gnome-tweaks
```

### 4. Extension Manager (GUI đẹp hơn):

```bash
# Ubuntu 22.04 trở lên:
flatpak install flathub com.mattjakeman.ExtensionManager
```

---

## 🎨 Tuỳ chỉnh Theme và Icon

```bash
mkdir -p ~/.icons
mkdir -p ~/.themes
tar -xJf Bibata-Modern-Ice.tar.xz -C ~/.icons
unzip your-file.zip -d ~/.icons
tar -xzf your-file.tar.gz -C ~/.icons
```

### 1. Theme

* Tải theme từ:
  🔗 [https://www.gnome-look.org/p/1687249](https://www.gnome-look.org/p/1687249)

* Giải nén vào:

  ```bash
  ~/.themes
  ```

### 2. Icon

* Duyệt thêm icon tại:
  🔗 [https://www.gnome-look.org/browse?cat=107\&ord=rating](https://www.gnome-look.org/browse?cat=107&ord=rating)  
  🔗 [https://draculatheme.com/gtk](https://draculatheme.com/gtk)

* Giải nén vào:

  ```bash
  ~/.icons
  ```

> 📌 Nếu chưa có folder `.themes` hoặc `.icons`, hãy tạo:

```bash
mkdir -p ~/.themes ~/.icons
```

---

## 🐧 Cài đặt Flatpak (Ubuntu)

🔗 [https://flatpak.org/setup/Ubuntu](https://flatpak.org/setup/Ubuntu)

---

## 🛠️ Thiết lập hệ thống Arch/Manjaro/Garuda sau cài đặt

> Tài liệu tham khảo: [15 Things After Installing Manjaro](https://www.fosslinux.com/46741/things-to-do-after-installing-manjaro.htm)

* ✅ Mở AUR: `Add/Remove Software` → Preferences → Enable AUR
* ✅ Cài `git`:

  ```bash
  sudo pacman -S git
  ```

---

## 📦 Cài đặt công cụ lập trình

| Phần mềm                          | Ghi chú / Link hướng dẫn                                                                                                                                                                                                                                                                                          |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **vim-plug**                      | [https://github.com/falcol/vim-plug-install](https://github.com/falcol/vim-plug-install)                                                                                                                                                                                                                          |
| **Telegram**                      | [https://discover.manjaro.org/applications/telegram-desktop](https://discover.manjaro.org/applications/telegram-desktop)                                                                                                                                                                                          |
| **Chrome + yay**                  | [https://itsfoss.com/install-chrome-arch-linux/](https://itsfoss.com/install-chrome-arch-linux/)                                                                                                                                                                                                                  |
| **VSCode**                        | [https://lobotuerto.com/blog/how-to-install-visual-studio-code-in-manjaro-linux/](https://lobotuerto.com/blog/how-to-install-visual-studio-code-in-manjaro-linux/)                                                                                                                                                |
| **MongoDB**                       | [https://stackoverflow.com/questions/59455725/install-mongodb-on-manjaro](https://stackoverflow.com/questions/59455725/install-mongodb-on-manjaro)                                                                                                                                                                |
| **Mongo Compass**                 | `pamac build mongodb-compass-beta-bin`                                                                                                                                                                                                                                                                            |
| **Redis**                         | [https://discover.manjaro.org/packages/redis](https://discover.manjaro.org/packages/redis)                                                                                                                                                                                                                        |
| **Docker**                        | [https://discover.manjaro.org/packages/docker](https://discover.manjaro.org/packages/docker)                                                                                                                                                                                                                      |
| **Docker Compose**                | [https://discover.manjaro.org/packages/docker-compose](https://discover.manjaro.org/packages/docker-compose)                                                                                                                                                                                                      |
| **FiraCode Font**                 | [https://www.nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads)                                                                                                                                                                                                                              |
| **Microsoft Fonts**               | [https://aur.archlinux.org/packages/ttf-ms-fonts/](https://aur.archlinux.org/packages/ttf-ms-fonts/)                                                                                                                                                                                                              |
| **ZSH**                           | [https://gist.github.com/yovko/becf16eecd3a1f69a4e320a95689249e](https://gist.github.com/yovko/becf16eecd3a1f69a4e320a95689249e)                                                                                                                                                                                  |
| **Neofetch**                      | [https://forum.manjaro.org/t/how-to-install-and-run-screenfetch-or-neofetch/10469](https://forum.manjaro.org/t/how-to-install-and-run-screenfetch-or-neofetch/10469)                                                                                                                                              |
| **IBus Bamboo**                   | [https://forum.manjaro.org/t/cai-d-t-ibus-bamboo-d-go-ti-ng-vi-t-tren-manjaro/7586](https://forum.manjaro.org/t/cai-d-t-ibus-bamboo-d-go-ti-ng-vi-t-tren-manjaro/7586)                                                                                                                                            |
|                                   | [https://github.com/BambooEngine/ibus-bamboo](https://github.com/BambooEngine/ibus-bamboo)                                                                                                                                                                                                                        |
| **Latte Dock**                    | `pacman -S latte-dock`                                                                                                                                                                                                                                                                                            |
| **PostgreSQL**                    | [https://www.youtube.com/watch?v=qtCeXcwIEAQ](https://www.youtube.com/watch?v=qtCeXcwIEAQ) + [https://tusharsadhwani.medium.com/how-to-setup-postgresql-and-pgadmin-on-manjaro-linux-arch-a76fa4404862](https://tusharsadhwani.medium.com/how-to-setup-postgresql-and-pgadmin-on-manjaro-linux-arch-a76fa4404862) |
| **Kiểm tra kết nối mạng hạn chế** | [https://wiki.archlinux.org/title/NetworkManager#Checking\_connectivity](https://wiki.archlinux.org/title/NetworkManager#Checking_connectivity)                                                                                                                                                                   |
| **NeoVim + Lua**                  | [https://github.com/neovim/neovim/blob/master/INSTALL.md](https://github.com/neovim/neovim/blob/master/INSTALL.md) + [https://nvchad.com/docs/config/theming](https://nvchad.com/docs/config/theming)                                                                                                             |

---

## 🌐 Biến môi trường cho IBus (bỏ vào `/etc/environment`)

```bash
export GTK_IM_MODULE=xim  # hoặc ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT4_IM_MODULE=ibus
export CLUTTER_IM_MODULE=ibus
export GLFW_IM_MODULE=ibus

ibus-daemon -drx
```

🔗 Fix lỗi IBus: [https://wiki.archlinux.org/title/IBus#Initial\_setup](https://wiki.archlinux.org/title/IBus#Initial_setup)

---

## 🖥️ Terminal Kitty

🔗 [https://discover.manjaro.org/applications/kitty](https://discover.manjaro.org/applications/kitty)

**Cấu hình gợi ý:**

```ini
font_family FiraCode      # Line 9
font_size   12.0          # Line 26
```

---

## 📐 Layout quản lý cửa sổ Kitty

```ini
enabled_layouts grid

map shift+up     move_window up
map shift+down   move_window down
map shift+left   move_window left
map shift+right  move_window right

map ctrl+up      neighboring_window up
map ctrl+down    neighboring_window down
map ctrl+left    neighboring_window left
map ctrl+right   neighboring_window right
```

---

## 🐍 Đổi version Python (Debian/Ubuntu)

🔗 [https://linuxconfig.org/how-to-change-from-default-to-alternative-python-version-on-debian-linux](https://linuxconfig.org/how-to-change-from-default-to-alternative-python-version-on-debian-linux)

---

## 🧹 Xoá Docker images bị dangling

```bash
sudo docker rmi $(docker images -a | grep "^<none>" | awk '{ print $3 }')
```

---

## 🧪 Ubuntu Setup

| Công cụ           | Link hướng dẫn                                                                                                                                                                     |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chrome**        | [https://itsfoss.com/install-chrome-ubuntu/](https://itsfoss.com/install-chrome-ubuntu/)                                                                                           |
| **Powerlevel10k** | [https://gist.github.com/cristian-aldea/c8f91187de922303fa10c6e5fd85e324](https://gist.github.com/cristian-aldea/c8f91187de922303fa10c6e5fd85e324)                                 |
| **Fix ACPI BIOS** | [https://askubuntu.com/questions/1411354/ubuntu-22-04-acpi-bios-error-bug](https://askubuntu.com/questions/1411354/ubuntu-22-04-acpi-bios-error-bug)                               |
| **ZSH TMUX auto** | Thêm vào `.zshrc`: `ZSH_TMUX_AUTOSTART=true`                                                                                                                                       |
| **Node.js**       | [https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04) |
| **Powerlevel10k** | [https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df](https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df)                                                   |

---
