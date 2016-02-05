# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Re-map sync'd dir so it has the same name as the module
  # Not doing this causes `puppet apply` to fail at catalog compile
  config.vm.synced_folder ".", "/home/vagrant/puppet-opendaylight", type: "rsync"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

  # We run out of RAM once ODL starts with default 500MB
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 4096
    libvirt.cpus = 2
  end

  config.vm.define "f23" do |f23|
    f23.vm.box = "fedora/23-cloud-base"

    f23.vm.provision "shell", inline: "dnf update -y"

    # Install required gems via Bundler
    f23.vm.provision "shell", inline: "dnf install -y rubygems ruby-devel gcc-c++ zlib-devel patch redhat-rpm-config make"
    f23.vm.provision "shell", inline: "gem install bundler"
    f23.vm.provision "shell", inline: "echo export PATH=$PATH:/usr/local/bin >> /home/vagrant/.bashrc"
    f23.vm.provision "shell", inline: "echo export PATH=$PATH:/usr/local/bin >> /root/.bashrc"
    f23.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle install" vagrant'
    f23.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle update" vagrant'

    # Git is required for cloning Puppet module deps in `rake test`
    f23.vm.provision "shell", inline: "dnf install -y git"

    # Install Docker for Docker-based Beaker tests
    f23.vm.provision "shell", inline: "tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/fedora/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
"
    f23.vm.provision "shell", inline: "dnf install -y docker-engine xfsprogs"
    f23.vm.provision "shell", inline: "usermod -a -G docker vagrant"
    f23.vm.provision "shell", inline: "systemctl start docker"
    f23.vm.provision "shell", inline: "systemctl enable docker"
  end

  config.vm.define "cent7" do |cent7|
    cent7.vm.box = "centos/7"

    cent7.vm.provision "shell", inline: "yum update -y"

    # Install required gems via Bundler
    cent7.vm.provision "shell", inline: "yum install -y rubygems ruby-devel gcc-c++ zlib-devel patch redhat-rpm-config make"
    cent7.vm.provision "shell", inline: "gem install bundler"
    cent7.vm.provision "shell", inline: "echo export PATH=$PATH:/usr/local/bin >> /home/vagrant/.bashrc"
    cent7.vm.provision "shell", inline: "echo export PATH=$PATH:/usr/local/bin >> /root/.bashrc"
    cent7.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle install" vagrant'
    cent7.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle update" vagrant'

    # Git is required for cloning Puppet module deps in `rake test`
    cent7.vm.provision "shell", inline: "yum install -y git"

    # Install Docker for Docker-based Beaker tests
    cent7.vm.provision "shell", inline: "tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
"
    cent7.vm.provision "shell", inline: "yum install -y docker-engine"
    cent7.vm.provision "shell", inline: "usermod -a -G docker vagrant"
    cent7.vm.provision "shell", inline: "systemctl start docker"
    cent7.vm.provision "shell", inline: "systemctl enable docker"
  end

end
