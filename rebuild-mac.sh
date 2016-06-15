#!/usr/bin/env zsh

cd $HOME

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
echo "Updating homebrew package list..."
brew update

echo "Installing homebrew binaries..."
binaries=(
    cmake
    elixir
    exiftool
    git
    gnu-getopt
    gsl
    less
    lua
    pandoc
    rsync
    the_silver_searcher
    tree
    vim
    youtube-dl
    zsh
)
brew install ${binaries[@]}

echo "Installing apps..."
brew install caskroom/cask/brew-cask
apps=(
    alfred
    android-file-transfer
    calibre
    dropbox
    google-chrome
    hammerspoon
    iterm2
    java
    karabiner
    macvim
    nvalt
    pdftk
    qlcolorcode
    qlmarkdown
    qlstephen
    seil
    skype
    sublime-text3
    tunnelblick
    vlc
)
brew cask install --appdir="/Applications" ${apps[@]}
brew cask alfred link

brew tap homebrew/dupes

echo "Installing fonts..."
brew tap caskroom/fonts
fonts=(
    font-inconsolata-g-for-powerline
)
brew cask install ${fonts[@]}

echo "Brews installed..."
brew list --versions
echo "Casks installed..."
brew cask list --versions

echo "Clone dotfiles from github..."
git clone https://github.com/gwww/dotfiles.git $HOME/.dotfiles
$HOME/.dotfiles/link.sh

echo "Installing zsh-antigen..."
mkdir -p $HOME/.antigen
curl -L https://raw.githubusercontent.com/zsh-users/antigen/master/antigen.zsh > antigen.zsh

echo "Installing rvm, latest ruby stable..."
curl -sSL https://get.rvm.io | bash -s stable --ruby

echo "Installing ruby gems..."
gems=(
    cucumber
    jekyll
    less
    page-object
    pry
    rb-gsl
    rspec
    therubyracer
)
gem install ${gems[@]} --no-ri --no-rdoc 

echo "Installing nvm, latest node stable, updating to latest npm..."
git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`
nvm install stable
npm install npm -g

echo "Installing python eggs..."
sudo easy_install -U pytest
sudo easy_install -U spritemapper
