#!/usr/bin/env bash

# only show active applications 
defaults write com.apple.dock static-only -bool TRUE
# position dock on left of screen
defaults write com.apple.dock orientation -string left
