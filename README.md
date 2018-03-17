# Vagrant::JunosCli

## Features

- Provision Junos OS boxes using CLI commands

## Usage

Install using standard Vagrant plugin installation methods.

```
$ vagrant plugin install vagrant-junos_cli
```

## Tested vagrant boxes

### vQFX
- juniper/vqfx10k-re

### vSRX
- juniper/ffp-12.1X47-D15.4

Note: When using the plugin with vSRX, the following configuration must be set in the Vagrantfile.

```
config.ssh.username = "vagrant"
config.ssh.private_key_path = "~/.vagrant.d/insecure_private_key"
```

## Quick Start

After installing the plugin you need to obtain a Junos box image.
Official boxes are available [here](https://github.com/Juniper/vqfx10k-vagrant).

```
$ vagrant box add juniper/vqfx10k-re
```

Create a Vagrantfile based on [one of the examples](https://github.com/Juniper/vqfx10k-vagrant/blob/master/light-1qfx/Vagrantfile).

```
Vagrant.configure('2') do |config|
  config.ssh.insert_key = false

  config.vm.define 'vqfx' do |vqfx|
    vqfx.vm.hostname = 'vqfx'
    vqfx.vm.box = 'juniper/vqfx10k-re'
    vqfx.vm.synced_folder '.', '/vagrant', disabled: true

    # Management port (em1 / em2)
    vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: 'reserved-bridge'
    vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'reserved-bridge'

    # (em3  em4)
    (1..2).each do |seg_id|
      vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'segment'
    end

    config.vm.provision 'junos_cli', path: 'provision.cmd'
  end
end
```

Note the `provision.cmd` file, referenced in the provisioner.
This is where your CLI commands should go.

```
configure private
set interfaces em3 unit 0 family inet address 10.0.0.1/24
commit
exit
```

Run `vagrant up` and the new box is getting created with the address configured.

## Configuration

Junos CLI provisioner accepts most parameters available for the [Shell provisioner](https://www.vagrantup.com/docs/provisioning/shell.html).
Do not pass `args` or `env`.

