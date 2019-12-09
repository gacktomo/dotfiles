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

curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
sudo sh -c "echo /usr/local/bin/fish >> /etc/shells"
chsh -s /usr/local/bin/fish
fish -l

cat << END

**************************************************
HOMEBREW INSTALLED! bye.
**************************************************

END
