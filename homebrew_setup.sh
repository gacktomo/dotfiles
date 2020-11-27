#!/bin/bash

# install homebrew
if ! command -v brew >/dev/null 2>&1; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo
fi

brew update
brew bundle
brew cleanup
brew cask cleanup

# setup fisher(fish package manager)
mkdir -p ~/.config/fish/functions
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# set default shell
sudo sh -c "echo /usr/local/bin/fish >> /etc/shells"
chsh -s /usr/local/bin/fish
fish -l
fisher update

cat << END

**************************************************
HOMEBREW INSTALLED! bye.
**************************************************

END
