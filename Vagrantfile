# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]

    vb.check_guest_additions = true

    # Display the VirtualBox GUI when booting the machine
    vb.gui = true

    # Set UI to scaled mode
    vb.customize ["setextradata", :id, "GUI/Scale", "true"]
  end

  config.vm.provision "shell", env: { USERNAME: 'test', PASSWORD: 'test' }, inline: <<~SHELL.strip
    set -euxo pipefail

    if ! grep "^$USERNAME:" /etc/passwd > /dev/null; then
      useradd -m --password "$(echo "$PASSWORD" | mkpasswd -s)" --comment "" -s "/bin/bash" "$USERNAME"
    fi

    if ! groups "$USERNAME" | grep -E "(^| )vagrant($| )" > /dev/null; then
      adduser "$USERNAME" vagrant
    fi
  SHELL

  config.vm.provision "shell", inline: <<~SHELL.strip
    apt-get install -y \
        task-gnome-desktop
  SHELL

  config.vm.provision "shell", inline: "apt-get update && apt-get upgrade -y"
end
