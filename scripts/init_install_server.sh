#!/bin/bash

#####
#
#
#
#####


echo -e "MAJ OS\n"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

echo -e "Configurations de l'OS\n"

sed -i -e "s/#alias ll='ls -l'/alias ll='ls -l'/g ~/.bashrc"
source ~/.bashrc

echo -e "Installation des dépendances\n"

sudo apt-get -y install curl
sudo apt-get -y install locate

echo -e "conf editeur vi\n"
sudo cp /etc/vim/vimrc /etc/vim/vimrc.old
sudo sed -i -e "s/\" let g:skip_defaults_vim/let g:skip_defaults_vim/g" /etc/vim/vimrc
sudo sed -i -e "s/\" syntax on/syntax on/g" /etc/vim/vimrc
sudo sed -i -e "s/\" set mouse=a/set mouse=/g" /etc/vim/vimrc

echo -e "MAJ base de données locate\n"
sudo updatedb

echo -e "Installation Yunohost\n"
cd /tmp
curl https://install.yunohost.org > install_yunohost

