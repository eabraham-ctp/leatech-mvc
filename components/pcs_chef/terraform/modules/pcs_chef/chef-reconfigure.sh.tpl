#!/bin/bash

# Make sure our proxy settings exist
source /etc/profile.d/proxy.sh


# Initial Configuration
chef-server-ctl reconfigure --accept-license

# Create admin user and org and make those available to the standard automation user for collection
sudo chef-server-ctl user-create ${admin_username} ${admin_firstname} ${admin_lastname} ${email_address} ${admin_password} -f ~${conn_user_name}/${admin_username}-${org}-${environment}.pem
sudo chef-server-ctl org-create ${org}-${environment} ${org} --association_user admin -f ~${conn_user_name}/${org}-${environment}-validator.pem

# Install chef-manage
chef-server-ctl install chef-manage
chef-server-ctl reconfigure
chef-manage-ctl reconfigure --accept-license

# Install push-jobs
chef-server-ctl install opscode-push-jobs-server
chef-server-ctl reconfigure
opscode-push-jobs-server-ctl reconfigure

# Install Reporting
chef-server-ctl install opscode-reporting
chef-server-ctl reconfigure
opscode-reporting-ctl reconfigure --accept-license
