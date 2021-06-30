#!/bin/bash

# setup fish
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish

#curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
sudo apt-get install fonts-powerline

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
