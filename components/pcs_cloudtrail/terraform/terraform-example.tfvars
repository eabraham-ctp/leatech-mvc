
ami                             = "ami-9bcd34e3"
#acidr for ssh and web access
deploymentserver_ip             = "10.160.66.254"
#Pick @end of subnet so other hosts don't lease it first from dhcp
instance_type                   = "c4.xlarge"
elb_internal                    = "false"
searchhead_count                = 1
indexer_count                   = 1
indexer_volume_size             = 140
pass4SymmKey                    = "e958a9dd3073e58ab566f3d7e5691ed5"
secret = "gLZuGsH/8i262xOPOb7ZQAOCzJRiXRoMGEzgJj7PiEPeu4UC8tXypJIPdf18Q4mipwFhilP6Za7XyAMcLkdVRveyswOKJKGRcPM0CchozYAnK1fLDTgjMuFyM6CyjXkS1h7qhpvu0xGFFarlr6wmq/xAtacScZ3o2PqzYIWGnew3pRgTOu7pw9uonzAdszpeSVh0aLCReEDDOKpgsj0t281lCAbcOmTfFHuQ1vwxn.yIpNeHcuoynHsEltkt9P"
ui_password                     = "password"

default_tags       = {
  ApplicationName   = "Splunk"
  Environment       = "Victor"
  Group             = "PSS"
  TechnicalResource = "Chris.Grove@cloudtp.com"
  BusinessOwner     = "Doug.Anastasia@cloudtp.com"
}
