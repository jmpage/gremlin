#!/usr/bin/env bash
# Temporary test file

gremlin feature curl install
gremlin feature github add-known-hosts
gremlin feature yadm install
gremlin feature yadm clone --verbose https://github.com/jmpage/dotfiles.git
