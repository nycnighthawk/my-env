#!/bin/bash

command -v apt &> /dev/null && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get -y autoremove

command -v yum &> /dev/null && \
    yum -y update

# install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugUpdate +PlugUpgrade +qall
vim +CocUpdate +qall
