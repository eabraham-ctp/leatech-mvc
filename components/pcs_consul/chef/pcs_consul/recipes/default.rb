# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul
#
# Install and configure Consul, either as a client or a server

# Need to minimally set these attributes
# default['consul']['config']['datacenter']
# default['consul']['config']['encrypt']

poise_service_user node['consul']['service_user'] do
  group node['consul']['service_group']
end

# install consul based on our configured attributes
include_recipe 'consul::default'

# install sumologic agent and by default send os-level log events
# include_recipe 'sumologic_agent::default'
