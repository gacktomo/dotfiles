#!/bin/bash

# install homebrew
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo
  printf '%s\n' '' 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/matsuo/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

sudo softwareupdate --install-rosetta
sudo xcodebuild -license accept

brew update
brew bundle
brew cleanup
brew cask cleanup

# setup fisher(fish package manager)
mkdir -p ~/.config/fish/functions
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# set default shell
sudo sh -c "echo /opt/homebrew/bin/fish >> /etc/shells"
chsh -s /opt/homebrew/bin/fish
fish -l
fisher update

# setup asdf(env manager)
asdf plugin add nodejs

cat << END

**************************************************
MacOS setting finish! bye.
**************************************************

END
