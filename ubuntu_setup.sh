#!/bin/bash

# setup fish, ghq
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish golang fonts-powerline -y
go get github.com/motemen/ghq

# setup fisher(fish package manager)
mkdir -p ~/.config/fish/functions
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# set default shell
chsh -s /usr/bin/fish
fish -l
fisher update

cat << END

**************************************************
MacOS setting finish! bye.
**************************************************

END
