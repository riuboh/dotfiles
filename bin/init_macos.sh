#!/bin/bash

# macOS以外を弾く
if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# 設定項目
defaults write com.apple.dock autohide -bool true                                 # Automatically hide or show the Dock
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true      # Avoid creating `.DS_Store` files on network volumes
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true                # Show the full POSIX path as Finder window title
defaults write com.apple.finder AppleShowAllFiles -bool true                      # Show hidden files in Finder
defaults write com.apple.finder ShowPathbar -bool true                            # Show path bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true                          # Show status bar in Finder
defaults write com.apple.finder ShowTabView -bool true                            # Show Tab bar in Finder
defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false # Disable live conversion

# 再起動
for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done
