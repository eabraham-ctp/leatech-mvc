#!/usr/bin/env bash

# Get and install ChefDK from the omnibus installer
# TODO: support multiple OS and ChefDK versions

source /etc/*release
echo "$ID"

case "$ID" in
       ( "rhel" )
            sudo yum update -y
            sudo yum install wget git -y
            wget https://packages.chef.io/files/current/chefdk/2.0.18/el/7/chefdk-2.0.18-1.el7.x86_64.rpm
            sudo rpm -ivh ./chefdk-2.0.18-1.el7.x86_64.rpm
            ;;
       ( * )
            #############
            # DO NOT REMOVE
            #  These lines are to avoid dpkg locks
            #
            sudo systemctl stop apt-daily.service
            sudo systemctl stop apt-daily.timer

            wget https://packages.chef.io/files/current/chefdk/2.0.18/ubuntu/16.04/chefdk_2.0.18-1_amd64.deb
            sudo dpkg -i chefdk_2.0.18-1_amd64.deb

            # Install Git
            sudo apt-get update
            sudo apt-get install git -y

            sudo dpkg -i chefdk_2.0.18-1_amd64.deb
            ;;

esac


# Setup the Git key and add Github to known hosts to avoid 'authenticity of host
# cannot be established' error
chmod 600 /tmp/git_id_rsa
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Get the cookbook repo from Git, using SSH key provided through Terraform
cd /tmp
ssh-agent bash -c 'ssh-add /tmp/git_id_rsa; git clone git@github.com:cloudtp/cap-mvc-chef.git'

mkdir -p cap-mvc-chef/nodes

# Get cookbook dependencies (merge into cookbooks from repo)
cd cap-mvc-chef/cookbooks/${wrapper_cookbook}
berks vendor ..

# Execute Chef
sudo chef-client -z -c /tmp/solo.rb -j /tmp/chef.json -o 'recipe[${wrapper_cookbook}::default]'

# Get rid of Git credentials
rm /tmp/git_id_rsa


# Clean up
case "$ID" in
       ( "rhel" )
             exit
            ;;
       ( * )
            sudo systemctl start apt-daily.service
            sudo systemctl start apt-daily.timer
            ;;
esac
