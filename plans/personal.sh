#!/usr/bin/env bash
# Foo
# bar

# https://stackoverflow.com/questions/496702/can-a-shell-script-set-environment-variables-of-the-calling-shell

#gremlin feature debian-backports setup
#...

gremlin feature lenovo-x1-carbon-gen12-fixes install

gremlin feature curl install
gremlin feature workspace create
gremlin feature dotfiles install

gremlin feature ripgrep install

gremlin feature emacs install
gremlin feature emacs-prelude install
gremlin feature dotfiles link-prelude-personal

gremlin feature cursor install
gremlin feature cursor install-extension kahole.magit
gremlin feature cursor install-extension enkia.tokyo-night

gremlin feature zsh install
gremlin feature oh-my-zsh install
gremlin feature asdf install
gremlin feature tmux install
gremlin feature alacritty install

gremlin feature fonts install \
        'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FantasqueSansMono/Bold-Italic/FantasqueSansMNerdFont-BoldItalic.ttf' \
        'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FantasqueSansMono/Italic/FantasqueSansMNerdFont-Italic.ttf' \
        'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FantasqueSansMono/Bold/FantasqueSansMNerdFont-Bold.ttf' \
        'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FantasqueSansMono/Regular/FantasqueSansMNerdFont-Regular.ttf'

gremlin feature firefox install
gremlin feature joplin install
gremlin feature dropbox install

gremlin feature gnome configure
