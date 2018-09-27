# -*- mode: ruby -*-
# vi: set ft=ruby :
# VARs
chef_user     = 'testlab@testlab.com'
chef_password = 'password'
chef_network  = '100.64.0'
# Install required Vagrant plugins
#missing_plugins_installed = false
#required_plugins = %w(vagrant-cachier vagrant-hostsupdater)

#required_plugins.each do |plugin|
#  if !Vagrant.has_plugin? plugin
#    system "vagrant plugin install #{plugin}"
#    missing_plugins_installed = true
#  end
#end
# If any plugins were missing and have been installed, re-run vagrant
#if missing_plugins_installed
  #exec "vagrant #{ARGV.join(" ")}"
#end

Vagrant.configure(2) do |config|

  config.vm.define :chef_server do |chef_server_config|
      chef_server_config.vm.box = "ubuntu/trusty64"
      chef_server_config.vm.hostname = "chef-server"
      chef_server_config.vm.network :private_network, ip: "#{chef_network}.10"
      chef_server_config.vm.network "forwarded_port", guest: 80, host: 8080
      chef_server_config.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
      end
      chef_server_config.vm.provision :shell,
      :path => "provision/bootstrap-chef-server.sh",
      :args => [chef_user,chef_password, chef_network]
  end

  # Part of the exercise
  # config.vm.define :lb do |lb_config|
  #     lb_config.vm.box = "bento/centos-7.1"
  #     lb_config.vm.hostname = "lb"
  #     lb_config.vm.network :private_network, ip: "10.0.15.15"
  #     lb_config.vm.network "forwarded_port", guest: 80, host: 8090
  #     lb_config.vm.provider "virtualbox" do |vb|
  #       vb.memory = "256"
  #     end
  #     lb_config.vm.provision :shell, path: "provision/nodes.sh"
  # end

  (2..3).each do |i|
    config.vm.define "web#{i}" do |node|
      node.vm.box = "bento/centos-7.2"
      node.vm.hostname = "web#{i}"
      node.vm.network :private_network, ip: "#{chef_network}.2#{i}"
      node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "256"
      end
      node.vm.provision :shell,
      :path => "provision/nodes-rhel.sh",
      :args => [chef_network]

    end
  end

  (1..1).each do |i|
    config.vm.define "web#{i}" do |node|
      node.vm.box = "bento/ubuntu-14.04"
      node.vm.hostname = "web#{i}"
      node.vm.network :private_network, ip: "#{chef_network}.2#{i}"
      node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "256"
      end
      node.vm.provision :shell,
      :path => "provision/nodes-ubuntu.sh",
      :args => [chef_network]

    end
  end
end
