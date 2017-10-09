#
# Cookbook:: base
# Recipe:: default
#

template "proxy.sh" do
  path   node[:proxy][:profile_script]
  source "proxy.sh.erb"
  owner  "root"
  group  "root"
  mode   "0755"
end

ruby_block "setenv-http_proxy" do
  block do
    Chef::Config.http_proxy  = "http://#{node[:proxy][:http_proxy]}:#{node[:proxy][:port]}"
    Chef::Config.https_proxy = "http://#{node[:proxy][:http_proxy]}:#{node[:proxy][:port]}"
    Chef::Config.no_proxy    = "http://#{node[:proxy][:no_proxy]}"
  end
end
  
hostname "#{Chef::Config[:node_name]}.#{node['private_domain']}"

# SUMO LOGIC
# create our log sources config directory
directory node['sumologic']['sync_config_dir'] do
  recursive true
end

# determine platform to help us with which
client_os = ''
case node['platform_family']
when 'debian','ubuntu'
  client_os = 'debian'
when 'centos','rhel','fedora','amazon'
  client_os = 'rhel'
end

# the individual sources that map to config files in the cookbook
log_sources = [
  'syslog',
  'secure',
  'audit'
]

node['sumologic']['sources'].each {|i| log_sources << i }
# cycle through the names of each of our pre-defined log sources to create each file
log_sources.each { |name|
  # create our log source for syslog
  template "#{node['sumologic']['sync_config_dir']}/#{name}.json" do
    source   "sumologic/log-sources/os/#{client_os}/#{name}.json.erb"

    # notifies :stop, 'service[collector]', :immediately
    # notifies :run, 'execute[sumo-uninstall]', :immediately
    # notifies :run, 'execute[sumo-reinstall]', :delayed
    # notifies :start, 'service[collector]', :delayed
  end
}


sumologic_collector node['sumologic']['installDir'] do
  collector_name    node['fqdn']
  proxy_host        node['proxy']['http_proxy']
  proxy_port        node['proxy']['port']
  sync_sources      node['sumologic']['sync_config_dir']
  sumo_access_id    node['sumologic']['accessId']
  sumo_access_key   node['sumologic']['accessKey']
end

include_recipe 'deep-security-agent'
