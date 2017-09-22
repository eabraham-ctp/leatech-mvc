{
  "consul": {
    "enable_webui": true,
    "config": {
      "datacenter": "${data_center}",
      "server": true,
      "encrypt": "tif3NuFR0Og2s5vAtkUYWw==",
      "bootstrap": ${bootstrap},
      "start_join": ["${ip_to_join}:8500"],
      "enable_syslog": true
    }
  }
}
