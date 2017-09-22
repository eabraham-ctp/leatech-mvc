server_name          = "${chef_elb}"
api_fqdn             = server_name
bookshelf['vip']     = server_name
nginx['url']         = "https://${chef_elb}"
nginx['server_name'] = server_name

