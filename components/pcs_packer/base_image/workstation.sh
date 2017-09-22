#!/bin/bash -xv

#VERSIONS
export TERRAFORM=0.9.11
export VAULT=0.7.3
export PACKER=1.0.4
export CHEFDK=2.1.11
export CONSUL=0.9.2


# Install system packages
sudo yum install wget unzip git -y

# RHEL comes pre-installed with Python but we still need to install pip
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

# Install AWS CLI using pip
sudo pip install awscli

# Install Terraform $TERRAFORM
wget https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip
unzip terraform_${TERRAFORM}_linux_amd64.zip
sudo cp terraform /usr/bin

# Install Vault
wget https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip
unzip vault_${VAULT}_linux_amd64.zip
sudo cp vault /usr/bin

# Install Packer
wget https://releases.hashicorp.com/packer/$PACKER/packer_${PACKER}_linux_amd64.zip
unzip packer_${PACKER}_linux_amd64.zip
sudo cp packer /usr/bin

# Install ChefDK
wget https://packages.chef.io/files/stable/chefdk/$CHEFDK/el/7/chefdk-${CHEFDK}-1.el7.x86_64.rpm
sudo rpm -ivh chefdk-${CHEFDK}-1.el7.x86_64.rpm

# Install Consul
wget https://releases.hashicorp.com/consul/$CONSUL/consul_${CONSUL}_linux_amd64.zip
unzip consul_${CONSUL}_linux_amd64.zip
sudo cp consul /usr/bin

# Install Dev tools and then Silver Searcher "ag
sudo yum group install -y  "Development Tools" 
sudo yum install -y pcre-devel xz-devel zlib zlib-devel pcre ppl

cd /tmp
# Lazy way to get a git repo so we don't have to worry about ssh knownhosts and ssh-keyscan etc
curl -f -o /tmp/ag.zip "https://codeload.github.com/ggreer/the_silver_searcher/zip/master"
unzip /tmp/ag.zip
cd /tmp/the_silver_searcher-master/
bash -c ./build.sh
sudo make install
