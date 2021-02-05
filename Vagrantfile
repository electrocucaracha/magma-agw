# -*- mode: ruby -*-
# vi: set ft=ruby :
##############################################################################
# Copyright (c)
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

$no_proxy = ENV['NO_PROXY'] || ENV['no_proxy'] || "127.0.0.1,localhost"
# NOTE: This range is based on sgi network definition CIDR 10.0.1.0/24
(1..254).each do |i|
  $no_proxy += ",10.0.1.#{i}"
end
$no_proxy += ",10.0.2.15"
$kernel_version="4.9.0-9"

Vagrant.configure("2") do |config|
  config.vm.provider :libvirt
  config.vm.provider :virtualbox

  config.vm.box = "generic/debian9"
  config.vm.hostname = "magma"
  config.vm.box_check_update = false
  config.vm.synced_folder './', '/vagrant'
  config.vm.network "private_network", ip: "172.21.0.13", :libvirt__network_name => "s1"

  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    # Install specific Kernel version
    if [ "$(uname -r)" != *"#{$kernel_version}"* ]; then
        DEBIAN_FRONTEND=noninteractive sudo -E apt remove -y --purge linux-image-*
        dpkg -l | grep linux-image | awk '{print$2}'
        echo "deb http://snapshot.debian.org/archive/debian/20190801T025637Z $(lsb_release -c -s) main non-free contrib" | sudo tee /etc/apt/sources.list.d/non-free.list
        sudo apt-get update
        sudo apt-get install -y linux-image-#{$kernel_version}-amd64 linux-headers-#{$kernel_version}-amd64
    fi

    # Disable predictable network interface names
    nics=$(ip -br a)
    if [[ ! $nics == *'eth0'*  ]] || [[ ! $nics == *'eth1'* ]] && [ -f /etc/default/grub ]; then
        # Predictable interface names 
        if  [[ "$(grep 'GRUB_CMDLINE_LINUX=' /etc/default/grub)" != *net.ifnames=0* ]]; then
            sudo sed -i "s|^GRUB_CMDLINE_LINUX\(.*\)\"|GRUB_CMDLINE_LINUX\1 net.ifnames=0\"|g" /etc/default/grub
        fi
        # biosdevname is a Dell attempt to solve a similar problem than predictable interface name in systemd.
        sudo apt-get purge biosdevname
        sudo update-initramfs -u
    fi
    if command -v grub-mkconfig; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        sudo update-grub
    elif command -v grub2-mkconfig; then
        grub_cfg="$(sudo readlink -f /etc/grub2.cfg)"
        if dmesg | grep EFI; then
            grub_cfg="/boot/efi/EFI/centos/grub.cfg"
        fi
        sudo grub2-mkconfig -o "$grub_cfg"
    fi
SHELL
  config.vm.provision :reload

  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    set -o pipefail
    set -o errexit

    cd /vagrant/
    ./install.sh | tee ~/install.log
    ./deploy.sh | tee ~/deploy.log
  SHELL
  config.vm.provision :reload
  config.vm.provision 'shell', privileged: false, path: "verify.sh"

  [:virtualbox, :libvirt].each do |provider|
  config.vm.provider provider do |p, override|
      p.cpus = 2
      p.memory = 1024*6
    end
  end

  config.vm.provider :libvirt do |v, override|
    v.cpu_mode = 'host-passthrough'
    v.random_hostname = true
    v.nested = true
    v.management_network_address = "10.0.1.0/24"
    v.management_network_name = "sgi"
  end

  config.vm.provider 'virtualbox' do |v, override|
    v.customize ["modifyvm", :id, "--nested-hw-virt","on"]
  end

  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil
    if Vagrant.has_plugin?('vagrant-proxyconf')
      config.proxy.http     = ENV['http_proxy'] || ENV['HTTP_PROXY'] || ""
      config.proxy.https    = ENV['https_proxy'] || ENV['HTTPS_PROXY'] || ""
      config.proxy.no_proxy = $no_proxy
      config.proxy.enabled = { docker: false }
    end
  end
end
