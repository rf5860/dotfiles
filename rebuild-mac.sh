#!/bin/zsh

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
echo "Updating homebrew..."
brew update

echo "Installing binaries..."
binaries=(
    elixir
    erlang
    git
    gnu-getopt
    gsl
    hub
    less
    npm
    rsync
    sqlite
    the_silver_searcher
    vim
)
brew install ${binaries[@]}

echo "Installing apps..."
brew install caskroom/cask/brew-cask
apps=(
    alfred
    calibre
    dropbox
    google-chrome
    hammerspoon
    iterm2
    java
    karabiner
    macvim
    nvalt
    pandoc
    pdftk
    qlcolorcode
    qlmarkdown
    qlstephen
    seil
    skype
    sublime-text3
    tree
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

brew list --versions
brew cask list

echo "Installing rvm, latest ruby stable..."
curl -sSL https://get.rvm.io | bash -s stable --ruby

echo "Installing ruby gems..."
gems=(
    byebug
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
