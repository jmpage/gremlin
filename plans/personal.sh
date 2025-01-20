#!/user/bin/env bash
# Foo
# bar

set -euxo pipefail

# https://stackoverflow.com/questions/496702/can-a-shell-script-set-environment-variables-of-the-calling-shell

gremlin feature dotfiles install

gremlin feature ripgrep install
gremlin feature emacs install
#gremlin feature emacs-prelude install

#gremlin feature dotfiles link-prelude-personal

gremlin feature cursor install
gremlin feature cursor install-extension kahole.magit
gremlin feature cursor install-extension enkia.tokyo-night

#gremlin feature alacritty install
#gremlin feature ohmyzsh install
#gremlin feature tmux install

# maybe take a list for this?
#gremlin feature fonts install #url (name)

# TODO gsettings / kde / etc
