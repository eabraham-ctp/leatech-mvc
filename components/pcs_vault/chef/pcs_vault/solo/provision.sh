#!/usr/bin/env bash

# Use our proxy if available
if [ $1 != "no-proxy" ]; then
    echo "export HTTP_PROXY=http://$1/" > /etc/profile.d/proxy.sh
    echo "export http_proxy=http://$1/" >> /etc/profile.d/proxy.sh
    echo "export HTTPS_PROXY=http://$1/" >> /etc/profile.d/proxy.sh
    echo "export https_proxy=http://$1/" >> /etc/profile.d/proxy.sh
    echo "export no_proxy=$2" >> /etc/profile.d/proxy.sh

    chmod a+x /etc/profile.d/proxy.sh
    source /etc/profile.d/proxy.sh
fi

yum group install -y  "Development Tools" 
/opt/chef/embedded/bin/gem install berkshelf
cd /var/tmp/pcs_vault	
/opt/chef/embedded/bin/berks vendor ..
/opt/chef/bin/chef-client -z -c /var/tmp/pcs_vault/solo/solo.rb -j /tmp/chef.json -o 'recipe[pcs_vault::default]'  #TECHDEBT better way to do this sort of thing 
