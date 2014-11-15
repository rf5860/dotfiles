#!/usr/bin/env zsh

# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;34m➜\033[0m  $@"; }

# Just in case there is a file starting with _ you don't want linked
ignore=(
)

dotfiles=`pwd`

# Cleanup existing symlinks to .dotfiles
for file in ~/.*; do
    if [[ -h $file ]]; then
        link=`readlink $file`
        if [[ $link =~ "^$dotfiles" ]]; then
            rm $file
        fi
    fi
done

for file in _*; do
  if [[ ${ignore[(r)$file]} != $file ]]; then
    file=$file[2,-1]
    if [[ ! -e ~/.$file || -h ~/.$file ]]; then
      if [[ -e $dotfiles/_$file ]]; then
        e_success "~/.$file symlinked to $dotfiles/_$file"
        ln -sf $dotfiles/_$file ~/.$file
      else
        e_error "$dotfiles/_$file does not exist; skipped"
      fi
    else
      e_error "~/.$file exists and is not a symlink; skipped"
    fi
  fi
done

exit
