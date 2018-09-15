# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "puppetlabs/ubuntu-16.04-64-nocm"
  config.vm.provision :shell, path: "puppet_deploy.sh"
  config.vm.provision "file", source: "module", destination: "/etc/puppetlabs/code/environments/production/modules"
  ##Expose the ports 8000 on guest and expose the same on host so that I can access the webpage on my local machine on port 8000 using ##http://localhost:8000
  config.vm.network "forwarded_port", guest: 8000, host: 8000
end


###List of available VM boxed you can replace with  under `config.vm.box`
#ubuntu-16.04-64-nocm
#puppetlabs/ubuntu-14.04-64-puppet
#puppetlabs/ubuntu-16.04-64-puppet
#puppetlabs/ubuntu-14.04-64-nocm
#puppetlabs/ubuntu-16.04-64-puppet
#ubuntu/trusty64
