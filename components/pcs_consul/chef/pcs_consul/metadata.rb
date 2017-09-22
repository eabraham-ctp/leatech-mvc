name 'pcs_consul'    #TECHDEBT rename this and fix the damn URLS
maintainer 'CTP CAP MVC team'
maintainer_email 'ctp-mvc@cloudtp.com'
license 'all_rights'
description 'Wrapper cookbook to install and configure Consul'
long_description 'Wrapper cookbook to install and configure Consul'
issues_url 'https://github.com/cap-mvc-chef.git' if respond_to?(:issues_url)
source_url 'https://github.com/cap-mvc-chef.git' if respond_to?(:source_url)
version '0.1.3'

depends 'consul', '>= 2.3.0'
# depends 'sumologic_agent', '>= 0.1.0', path: '../sumologic_agent'
# depends 'sumologic-collector', '~> 1.2.19'
