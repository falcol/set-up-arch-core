#!/bin/bash
rm -rf ~/.cache/*
sudo pacman -Rns $(pacman -Qtdq)
sudo pacman -Sc
rmlint /home/
sudo systemctl start paccache.service
