{
  "consul": {
    "config": {
      "datacenter": "${data_center}",
      "encrypt": "tif3NuFR0Og2s5vAtkUYWw==",
      "start_join": [
        "${consul_address}"
      ]
    }
  },
  "omnibus-gitlab": {
    "package": {
      "version": "${gitlab_version}"
    },
    "gitlab_rb": {
      "external_url": "http://${server_private_ip}"
    }
  },
    "sumologic": {
      "sources": ["gitlab"]
  }
}