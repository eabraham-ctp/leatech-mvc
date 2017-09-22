# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
#

# install and configure Vault server based on our configured attributes
poise_service_user node['consul']['service_user'] do
  group node['consul']['service_group']
end

# install consul based on our configured attributes
include_recipe 'consul::default'

include_recipe 'hashicorp-vault'


# install sumologic agent and by default send os-level log events
# include_recipe 'sumologic_agent::default'
