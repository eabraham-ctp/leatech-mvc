{
	"hashicorp-vault": {
		"config": {
			"address": "${server_private_ip}:8200",
			"backend_type": "consul",
			"backend_options": {
				"disable_registration ": "false",
				"service": "vault-pcs",
				"address": "${consul_address}:8500",
				"path": "vault"
			}
		}
	},
	"consul": {
		"config": {
			"datacenter": "${data_center}",
			"encrypt": "tif3NuFR0Og2s5vAtkUYWw==",
			"start_join": ["${consul_address}:8500"]
		}
	}
}