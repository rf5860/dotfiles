dotfiles
========

The dot files for my login and a couple of scripts to rebuild the environment.

Files in this directory that start with an '_' will be linked to the equivalent
'.' name in the home directory when the script `link.sh` is run.

`rebuild-mac.sh` attempts to recreate my software environment. Missing is
software from the App Store.

`osx.sh` recreates my settings.

Since private user information is in .gitconfig, that information is separated
out into the file "gitconfig.private" which is not in version control. The
contents of that file are in standard .gitconfig file format.
