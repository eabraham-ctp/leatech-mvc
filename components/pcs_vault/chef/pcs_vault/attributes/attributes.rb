# Vault settings
default['hashicorp-vault']['version'] = '0.7.3'

default['consul']['version'] = '0.8.3'
# Consul agent settings (default is configured for agent settings)
# default['consul']['config']['server']    = false
# default['consul']['config']['ui']        = false
# default['consul']['config']['bootstrap'] = false
#
# default['consul']['config']['bind_addr']          = node['ipaddress']
# default['consul']['config']['advertise_addr']     = node['ipaddress']
# default['consul']['config']['advertise_addr_wan'] = node['ipaddress']

# Sumologic collector settings (these should be moved)
default['sumologic']['accessid']        = ENV["SUMO_ACCESS_ID"] || 'your-sumo-accessid'
default['sumologic']['accesskey']       = ENV["SUMO_ACCESS_KEY"] || 'your-sumo-accesskey'
default['sumologic']['collector_name']  = "#{node['hostname']}-#{node['ipaddress']}"
default['sumologic']['sync_config_dir'] = '/opt/SumoCollector/sources.d'
default['sumologic']['cpu_target']      = '20'

# The following attributes are strictly for Inspec Unit/Integration testing purposes
# - determine our path for creating the node attributes JSON dump to assist our inspec tests
default['export-node']['location']  = File.join(ENV["TEMP"] || "/tmp", "kitchen")
