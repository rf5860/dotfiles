#!/usr/bin/env bash

# only show active applications 
defaults write com.apple.dock static-only -bool TRUE

# position dock on left of screen
defaults write com.apple.dock orientation -string left

# Quit printer app when printing is complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# This setting will turn off the keyboard lights when the keyboard is not touched for five minutes. 
defaults write com.apple.BezelServices kDimTime -int 300

# Preview Window enable copy text 
defaults write com.apple.finder QLEnableTextSelection -bool true

# Disable .DS_Store files on Network Volumes Windows 
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Setting trackpad & mouse speed to a reasonable number
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

# Enabling subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Always open everything in Finder's list view.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set a really fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 0

# Set the Finder prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
