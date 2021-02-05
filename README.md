# Magma Access Gateway setup
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Summary

This project is used to disect and understand the Access Gateway
deployment process described in the [Official documentation][1]. These
instructions don't pretend to replace the scripts provided by the
community.

## Virtual Machines

The [Vagrant tool][2] is used for provisioning a Debian Stretch Virtual
Machine. It's highly recommended to use the  *setup.sh* script
of the [bootstrap-vagrant project][3] for installing Vagrant
dependencies and plugins required for this project. That script
supports two Virtualization providers (Libvirt and VirtualBox) which
are determine by the **PROVIDER** environment variable.

    $ curl -fsSL http://bit.ly/initVagrant | PROVIDER=libvirt bash

Once Vagrant is installed, it's possible to provision a Virtual
Machine using the following instructions:

    $ vagrant up

[1]: https://docs.magmacore.org/docs/lte/setup_deb
[2]: https://www.vagrantup.com/
[3]: https://github.com/electrocucaracha/bootstrap-vagrant
