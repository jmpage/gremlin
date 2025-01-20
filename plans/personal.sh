#!/user/bin/env bash
# Foo
# bar

set -euxo pipefail

# https://stackoverflow.com/questions/496702/can-a-shell-script-set-environment-variables-of-the-calling-shell
# https://github.com/jmpage/dhow/blob/main/provision/scripts/install-arkenfox.sh

# gremlin xinstall / xsetup should print a message that it would and continue

#gremlin feature dotfiles install # makes dotfiles command available?

gremlin feature emacs install
#gremlin feature emacs-prelude install
gremlin feature ripgrep install

#gremlin setup emacs-prelude-personal
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
