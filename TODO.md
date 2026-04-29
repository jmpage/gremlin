- [ ] Use cached credentials for sudo (-v)

# Logging

- [ ] Redirect output of things to /dev/null or stderr depending on whether or not log level is TRACE

# Consistency

- [x] Rename primary shell scripts to not end in .sh

# Fixes

- [ ] Switch to using long-options instead of short options in code
- [ ] bug where debian fixes for lenovo erroneously sets up multiple sources:

# Security

- [ ] Support specifying version to install
  - [ ] asdf is missing version check w/ upgrade
  - [ ] cursor
  - [ ] joplin
  - [ ] prelude
- [ ] Support verifying checksums
  - [ ] alacritty
  - [ ] cursor
  - [ ] joplin
  - [ ] prelude
- [ ] Do not download and execute arbitrary scripts from the internet
  - [ ] emacs-prelude
  - [ ] homebrew
  - [ ] joplin
  - [ ] oh-my-zsh

# Deduplication

- [ ] Extract mtree comparison code
  - From emacs and alacritty

# Missing skips
- [ ] Firefox
  - [ ] skip if already installed on macos
  - [ ] skip if already installed on debian
- [ ] Cursor
  - [ ] skip if version is already installed on debian
  - [ ] skip if version is already installed on macos

# Portability

- [ ] MacOS support
  - [ ] dropbox
  - [ ] joplin

# Testability

- [ ] Add MacOS VM tests
- [ ] Test sequential runs
- [ ] Vagrant support for sequential runs
- [ ] write shellspec for support scripts: https://shellspec.info/
- [ ] rename bin/vagrant to something else
- [ ] overhaul bin/vagrant to support parameterization, etc.

# Features

- [ ] Install joplin plugins
- [ ] Configure MacOS defaults
