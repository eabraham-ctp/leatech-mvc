#
# Cookbook Name:: artifactory
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'pcs_artifactory::install'



# for unit/integration testing with kitchen/inspec
if node['sumologic']['is_unit-test']
  include_recipe 'inspec_helper::default'
  node.default['omnibus-gitlab']['gitlab_rb']['external_url'] = "http://#{node['ipaddress']}"
end
