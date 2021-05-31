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
### ibus-bamboo https://forum.manjaro.org/t/cai-d-t-ibus-bamboo-d-go-ti-ng-vi-t-tren-manjaro/7586
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
