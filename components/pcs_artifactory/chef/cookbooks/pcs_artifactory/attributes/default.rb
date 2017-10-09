# configuration attributes for artifactory

default['base']['repos_strict'] = false
default['base']['restore_data'] = false
default['base']['jdk']['version'] = "1.8.0"

# default['base']['artifactory']['ldap_url'] = "ldaps://#{node['ldap_servers']['ldap_host']}"
# default['base']['artifactory']['ldap_port'] = "#{node['ldap_servers']['port']}"
# default['base']['artifactory']['managerDn'] = "#{node['ldap_servers']['bind_dn']}"
# default['base']['artifactory']['managerPassword'] = "#{node['ldap_servers']['bind_password']}"

#  SSL settings for artifactory
default['base']['artifactory']['web_port'] = "8443"
default['base']['artifactory']['server_crt'] = "/etc/opt/jfrog/artifactory/server.crt"
default['base']['artifactory']['server_key'] = "/etc/opt/jfrog/artifactory/server.key"
default['base']['artifactory']['git_url'] = "github.com/cloudtp"
default['base']['artifactory']['git_project'] = "mvc-chef"

default['consul']['version'] = '0.8.3'

default['sumologic']['sources']         = ['artifactory']

#```````````````````````
# Testing attributes
#,,,,,,,,,,,,,,,,,,,,,,,

# We override this attribute in our .kitchen.yml so that default recipe dumps the node attributes to the filepath below
default['sumologic']['is_unit_test'] = false

# The following attributes are strictly for Kitchen and Inspec Unit/Integration testing purposes
# - Predetermine our path for creating the node attributes JSON dump to assist our inspec tests with locating the file at runtime
default['export-node']['location']  = File.join(ENV["TEMP"] || "/tmp", "kitchen")
