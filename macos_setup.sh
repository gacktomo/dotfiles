#!/bin/bash

# Mac OS Preferences

## Remove all apps from the dock
defaults write com.apple.dock persistent-apps -array
## Hide recent apps in the dock
defaults write com.apple.dock "show-recents" -bool "false"
# Disable recent spaces
defaults write com.apple.dock "mru-spaces" -bool "false"
## Show all filename extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
# Auto hide dock
defaults write com.apple.dock autohide -bool true
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Display battery level in the menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
# Display date, day, and time in the menu bar
defaults write com.apple.menuextra.clock DateFormat -string 'EEE d MMM HH:mm:ss'
# Increase keyboard initial delay
# warning: less than 10 is not recommended. too fast to type
defaults write -g InitialKeyRepeat -int 20
# Increase keyboard repeat rate
defaults write -g KeyRepeat -int 1.5
# Increase mouse speed
defaults write -g com.apple.mouse.scaling 1.5
# Increase trackpad speed
defaults write -g com.apple.trackpad.scaling 2
## Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool "true"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool "true"
defaults -currentHost write -g com.apple.mouse.tapBehavior -bool "true"
## Drag with three finger
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true && \
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

## Swap CapsLock <-> Control
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'

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

echo "Setting asdf plugins"
# setup asdf(env manager)
asdf plugin add nodejs

echo "Setting karabiner"
# Copy karabiner files
mkdir -p ~/.config/karabiner
ln -sf ~/dotfiles/dist/karabiner/karabiner.json ~/.config/karabiner
ln -sf ~/dotfiles/dist/karabiner/karabiner.edn ~/.config
# goku # karabiner setting

# setup fisher(fish package manager)
mkdir -p ~/.config/fish/functions
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# set default shell
echo "Setting fish"
sudo sh -c "echo /opt/homebrew/bin/fish >> /etc/shells"
chsh -s /opt/homebrew/bin/fish
fish -c "fisher update"

echo -n "You will need reboot macOS. Are you sure? [Y/n]: "
read ANS

case $ANS in "" | [Yy]* )
	# Yes
	launchctl bootout user/$(id -u)
	;; * )
	# No
	;;
esac

cat << END

**************************************************
MacOS setting finish!
**************************************************

END
