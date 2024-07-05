
Vagrant.configure("2") do |config|
 

  # Define the server machine
  config.vm.define "server" do |server|
    server.vm.box = "debian/bullseye64"
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: "192.168.50.11"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
    server.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y sshpass
      echo "root:reditall" | sudo chpasswd
      sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sudo systemctl restart ssh
      # Set hostname
      hostnamectl set-hostname server
      echo "127.0.1.1 server.kubernetes.local server" >> /etc/hosts
    SHELL
  end

  # Define the node0 machine
  config.vm.define "node0" do |node0|
    node0.vm.box = "debian/bullseye64"
    node0.vm.hostname = "node0"
    node0.vm.network "private_network", ip: "192.168.50.12"
    node0.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
    node0.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y sshpass
      echo "root:reditall" | sudo chpasswd
      sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sudo systemctl restart ssh
      # Set hostname
      hostnamectl set-hostname node0
      echo "127.0.1.1 node0.kubernetes.local node0" >> /etc/hosts
    SHELL
  end

  # Define the node1 machine
  config.vm.define "node1" do |node1|
    node1.vm.box = "debian/bullseye64"
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.50.13"
    node1.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
    node1.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y sshpass
      echo "root:reditall" | sudo chpasswd
      sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sudo systemctl restart ssh
      # Set hostname
      hostnamectl set-hostname node1
      echo "127.0.1.1 node1.kubernetes.local node1" >> /etc/hosts
    SHELL
  end

  # Define the jumpbox machine
  config.vm.define "jumpbox" do |jumpbox|
    jumpbox.vm.box = "debian/bullseye64"
    jumpbox.vm.hostname = "jumpbox"
    jumpbox.vm.network "private_network", ip: "192.168.50.10"
    jumpbox.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
    jumpbox.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y wget curl vim openssl git sshpass
      echo "root:reditall" | sudo chpasswd
      sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sudo systemctl restart ssh
      # Generate SSH key if not already present
      if [ ! -f /root/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ''
      fi
    SHELL
    jumpbox.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "/vagrant/scripts/post_provision.yml"
      ansible.inventory_path = "/vagrant/scripts/inventory.ini"
    end
  end

end
