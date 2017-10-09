#
# Cookbook Name:: artifactory
# Recipe:: repo
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

case node['platform']
when 'debian', 'ubuntu'
  template '/tmp/ubuntu_pre.sh' do
    source 'ubuntu-bintray-jfrog-artifactory-pro-rpms.repo.erb'
    mode '0755'
  end

  execute 'apache_configtest' do
    command '/tmp/ubuntu_pre.sh'
    not_if 'ls -l /etc/opt/jfrog'
  end

when 'redhat', 'centos', 'fedora', 'amazon', 'scientific', 'oracle'
  template '/etc/yum.repos.d/bintray-jfrog-artifactory-pro-rpms.repo' do
    source 'rhel-bintray-jfrog-artifactory-pro-rpms.repo.erb'
    mode '0644'
  end

  template '/etc/yum.repos.d/nginx.repo' do
    source 'nginx.repo.erb'
  end

when 'centos', 'fedora', 'amazon', 'scientific'
  package 'epel-release' do
    action :install
  end

end
