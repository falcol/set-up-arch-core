# install garuda
## create usb: 
```
burn usb:  sudo dd bs=4M if=/path/to/file.iso of=/dev/sd[drive letter] status=progress oflag=sync
check sd:  `sudo fdisk -l`
```

```
size    file         flags     mount
512MB   fat32        boot      boot/efi
16G     linuxswap    swap       None    
all     btrfs                   /
```
or https://www.hacknos.com/garuda-linux-installation/

# install manjaro
```
size      file          flags      mount
512MB     fat32        boot        boot/efi
16G       linuxswap    swap        None 
25G       ext4                     /
30G       ext4                     /home
```
change mirror: 
```
  - manjaro
   sudo pacman-mirrors -s --country Japan,Singapore,Hong_Kong,South_Korea,Germany,Netherlands
   sudo pacman -Syy
  - garuda: sudo reflector --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && cat /etc/pacman.d/mirrorlist && sudo pacman -Syu
```
# set-up-arch-core 
set up for arch, manjaro, garuda

### open aur : add/remove software => preferences => enable AUR    
### install git `sudo pacman -S git`    
### vim-plug https://github.com/falcol/vim-plug-install
### telegram https://discover.manjaro.org/applications/telegram-desktop
### chrome + yay https://itsfoss.com/install-chrome-arch-linux/
### vscode https://lobotuerto.com/blog/how-to-install-visual-studio-code-in-manjaro-linux/   
### mongodb https://stackoverflow.com/questions/59455725/install-mongodb-on-manjaro
### mongodb-compass `pamac build mongodb-compass-beta-bin`   
### redis https://discover.manjaro.org/packages/redis
### docker https://discover.manjaro.org/packages/docker
### docker-compose https://discover.manjaro.org/packages/docker-compose
### font firacode https://github.com/tonsky/FiraCode
### font microsoft https://aur.archlinux.org/packages/ttf-ms-fonts/
### ibus-bamboo https://forum.manjaro.org/t/cai-d-t-ibus-bamboo-d-go-ti-ng-vi-t-tren-manjaro/7586 or https://github.com/BambooEngine/ibus-bamboo
````
export GTK_IM_MODULE=xim or ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
# Dành cho những phần mềm dựa trên qt4
export QT4_IM_MODULE=ibus
# Dành cho những phần mềm dùng thư viện đồ họa clutter/OpenGL
export CLUTTER_IM_MODULE=ibus
export GLFW_IM_MODULE=ibus
ibus-daemon -drx
````
in /etc/environment

if error https://wiki.archlinux.org/title/IBus#Initial_setup


### kitty terminal https://discover.manjaro.org/applications/kitty   
  line 9 : font_family FiraCode    
  line 26 : font_size 12.0    
#### IN Layout managemant  
```enabled_layouts grid                                                           
map shift+up move_window up                                                   
map shift+left move_window left                                                
map shift+right move_window right                                              
map shift+down move_window down                                                
                                                                                 
map ctrl+left neighboring_window left                                          
map ctrl+right neighboring_window right                                        
map ctrl+up neighboring_window up                                              
map ctrl+down neighboring_window down```
