variable "org"                              {}
variable "environment"                      {}
variable "app"                              {}
variable "group"                            {}

## AWS Specific part
variable  "ami"                             {}
variable  "instance_user"                   {}
variable  "key_name"                        {}
variable  "vpc_id"                          {}

#AZ lists and subnets must be comma separated lists in the same order ( subnet 1 must be in AZ 1)
variable  "availability_zones"              {}
variable  "subnets"                         {}
#admin cidr for ssh and web access
variable  "vpc_cidr"                        {}
# Pick an address far in the subnet to make sure other hosts don't take it first on dhcp
variable  "deploymentserver_ip"             {}

variable  "instance_type"                   {}
variable  "elb_internal"                    {}
variable  "elb_port"                        { default = 80}
variable  "httpport"                        { default = 8000 }
variable  "replication_port"                { default = 9887 }
variable  "management_port"                 { default = 8089 }
variable  "splunk_ports"                    { default=[8000,9887,8089,9997]}
variable  "indexer_volume_size"             { default = "50" }

variable  "pass4SymmKey"                    {}
variable  "ui_password"                     {}
variable  "secret"                          {}
variable  "replication_factor"              { default = 2 }
variable  "search_factor"                   { default = 2 }
variable  "searchhead_count"                {}
variable  "indexer_count"                   {}
variable  "sqs_queue"                       {}

variable "default_tags"                     {type="map"}
variable "common_sg"                        {}
variable "squid_elb_sg"                     {}
variable "ssh_sg"                           {}
variable "openvpn_sg"                       {}
variable "vpc_security_group_ids"           {type="list"}
