name 'pcs_vault'
maintainer 'CTP CAP MVC team'
maintainer_email 'ctp-mvc@cloudtp.com'
license 'all_rights'
description 'Wrapper cookbook to install and configure Vault'
long_description 'Wrapper cookbook to install and configure Vault'
issues_url 'https://github.com/mvc-chef.git' if respond_to?(:issues_url)
source_url 'https://github.com/mvc-chef.git' if respond_to?(:source_url)
version '0.1.4'

depends 'hashicorp-vault', '~> 2.5.0'
depends 'consul', '>= 2.3.0'

# depends 'sumologic_agent', '>= 0.1.0', path: '../sumologic_agent'
