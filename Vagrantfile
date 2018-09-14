# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "puppetlabs/ubuntu-16.04-64-nocm"
  config.vm.provision :shell, path: "puppet_deploy.sh" 
  config.vm.provision "file", source: "module", destination: "/etc/puppetlabs/code/environments/production/modules"
  config.vm.network "forwarded_port", guest: 8000, host: 8000
end
