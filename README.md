## Learn Chef by doing.

This Lab will help you understand the whole concept of Chef/Chef Server/Chef DK/Knife and all Chef utilities
that revolve around provisioning boxes.

The end goal of this project is be able to setup the following:
* Run Chef Server locally on a Vagrant virtual machine.
* Provision 1 load balancer and 2 Web applications through Chef
* Write your own cookbooks and deploy them to Chef Server.
* Write tests for Chef

This would be the end result of this provisioning:

![](https://github.com/weldpua2008/chef-lab/blob/master/images/diagram.PNG)

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/)
* [Chef Development Kit - ChefDK](https://downloads.chef.io/chef-dk/)

## Steps by OS
* [Windows](docs\README-WINDOWS.md)
* [macOS](docs\README-MACOS.md)

## Configuration Knife
* [macOS](docs\KNIFE-VAGRANT-MACOS.md)


## Fixing Isuses

### Could not load the 'vagrant' driver from the load path.
```
$ kitchen list
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ClientError
>>>>>> Message: Could not load the 'vagrant' driver from the load path. Please ensure that your driver is installed as a gem or included in your Gemfile if using Bundler.
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
```
check versions
```
$ vagrant --version
Vagrant 2.1.4
$ chef gem list kitchen-vagrant

*** LOCAL GEMS ***

kitchen-vagrant (1.3.2)

chef -v && kitchen -v && chef gem list inspec

```
#### [Reinstall chefdk](https://docs.chef.io/uninstall.html)
Use the following commands to remove the Chef development kit on macOS.

```
sudo rm -rf /opt/chefdk
sudo pkgutil --forget com.getchef.pkg.chefdk
sudo find /usr/local/bin -lname '/opt/chefdk/*' -delete
sudo find /usr/bin -lname '/opt/chefdk/*' -delete
sudo gem list|grep chef
sudo gem uninstall chef chef-config chef-zero
sudo gem list|grep knife
```

If no Help, Check  https://github.com/berkshelf/berkshelf/issues/1755
```
sudo gem install kitchen-inspec
sudo gem install berkshelf -v 6.3.2

```
