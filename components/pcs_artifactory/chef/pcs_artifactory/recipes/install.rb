#G
# Cookbook Name:: artifactory
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#does_jfrog_repo_exist = File.exist?('/etc/yum.repos.d/artifactory.repo')

#if node['base']['repos_strict'] == false
#  jdk = "java-#{node['base']['jdk']['version']}-openjdk"
#  package jdk do
#    action [:install, :upgrade]
#  end
#end

#include_recipe 'artifactory::repo' if !does_jfrog_repo_exist

if node['base']['repos_strict'] == false
  include_recipe 'pcs_artifactory::repo'
end

%w(jfrog-artifactory-pro git).each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

case node['platform']
when 'debian', 'ubuntu'
  jdk = "openjdk-8-jdk"
when 'redhat', 'centos', 'fedora', 'amazon', 'scientific', 'oracle'
  jdk = "java-#{node['base']['jdk']['version']}-openjdk"
end

package jdk do
  action [:install, :upgrade]
end


template '/etc/opt/jfrog/pass' do
  source 'pass.erb'
  mode '0600'
  owner 'root'
  group 'root'
end

template '/etc/opt/jfrog/root' do
  source 'root'
  mode '0600'
  owner 'root'
  group 'root'
  notifies :run, 'execute[Install root cert]', :delayed
end

execute 'Install root cert' do
  command 'cat /etc/opt/jfrog/pass | keytool -import -alias rootcert -keystore /etc/opt/jfrog/artifactory/cacerts -noprompt -trustcacerts -file root && chown artifactory:artifactory /etc/opt/jfrog/artifactory/cacerts '
  cwd '/etc/opt/jfrog'
  action :nothing
end

template '/etc/opt/jfrog/legacy' do
  source 'legacy'
  mode '0600'
  owner 'root'
  group 'root'
  notifies :run, 'execute[Install legacy cert]', :delayed
end

execute 'Install legacy cert' do
  command 'cat /etc/opt/jfrog/pass | keytool -import -alias ralegacy -keystore /etc/opt/jfrog/artifactory/cacerts -noprompt -trustcacerts -file legacy && chown artifactory:artifactory /etc/opt/jfrog/artifactory/cacerts '
  cwd '/etc/opt/jfrog'
  action :nothing
end

template '/etc/opt/jfrog/intermediate' do
  source 'intermediate'
  mode '0600'
  owner 'root'
  group 'root'
  notifies :run, 'execute[Install intermediate cert]', :delayed
end

execute 'Install intermediate cert' do
  command 'cat /etc/opt/jfrog/pass | keytool -import -alias raintermediate -keystore /etc/opt/jfrog/artifactory/cacerts -noprompt -trustcacerts -file intermediate && chown artifactory:artifactory /etc/opt/jfrog/artifactory/cacerts '
  cwd '/etc/opt/jfrog'
  action :nothing
end

template '/etc/opt/jfrog/artifactory/default' do
  source 'default'
  mode '0644'
  owner 'artifactory'
  group 'artifactory'
  notifies :restart, 'service[artifactory]', :delayed
end

template '/etc/opt/jfrog/artifactory/artifactory.config.latest.xml' do
  source 'artifactory.config.latest.xml.erb'
  mode '0664'
  owner 'artifactory'
  group 'artifactory'
  notifies :restart, 'service[artifactory]', :delayed
end

template '/etc/opt/jfrog/artifactory/artifactory.lic' do
  source 'artifactory.lic'
  mode '0664'
  owner 'artifactory'
  group 'artifactory'
  notifies :restart, 'service[artifactory]', :delayed
end

service 'artifactory' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action  [:enable, :restart]
end

package 'nginx' do
  action [:install, :upgrade]
end

case node['platform']
when 'debian', 'ubuntu'
  perms = "www-data"
when 'redhat', 'centos', 'fedora', 'amazon', 'scientific', 'oracle'
  perms = "nginx"
end

template '/etc/nginx/nginx.conf' do
  variables({
    :perms => perms
  })
  source 'nginx.conf.erb'
  mode '0644'
  owner #{perms}
  group #{perms}
  notifies :restart, 'service[nginx]', :delayed
end

template '/etc/opt/jfrog/artifactory/server.crt' do
  source 'server.crt'
  mode '0644'
  notifies :restart, 'service[nginx]', :delayed
end

template '/etc/opt/jfrog/artifactory/server.key' do
  source 'server.key'
  mode '0644'
  notifies :restart, 'service[nginx]', :delayed
end

execute 'Fix ownership nginx' do
  command 'chown -R #{perms}:#{perms} /etc/nginx '
  only_if 'ls -l /etc/nginx | grep -v #{perms} | grep -v total '
end

include_recipe 'selinux_policy::install'

selinux_policy_boolean 'httpd_can_network_connect' do
    value true
end

service 'nginx' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action  [:enable, :start]
end

execute 'mounted /dev/vdb1 ' do
  command 'echo "/dev/vdb1 /var/opt/jfrog/artifactory               ext4     defaults     0 0 " >> /etc/fstab '
  not_if 'grep /dev/vdb1 /etc/fstab '
end

directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0750'
  action :create
end

template '/root/.ssh/id_rsa' do
  source 'id_rsa'
  mode '0600'
end

template '/tmp/post_tasks.sh' do
  source 'post_tasks.sh.erb'
  mode '0755'
end

if node['base']['restore_data'] == true
  execute 'Run Post config tasks' do
    command '/tmp/post_tasks.sh'
    not_if 'ls /tmp/artifactory-config/base/ '
  end
end
