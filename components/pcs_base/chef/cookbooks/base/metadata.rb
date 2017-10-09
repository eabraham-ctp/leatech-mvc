name 'base'
maintainer 'Byron Jones'
maintainer_email 'byron.jones@cloudtp.com'
license 'All Rights Reserved'
description 'Installs/Configures base'
long_description 'Installs/Configures base'
version '0.1.1'
chef_version '>= 12.1' if respond_to?(:chef_version)
depends "chef_hostname"
depends "sumologic-collector"
depends 'deep-security-agent'
depends 'timezone_iii'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/base/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/base'
