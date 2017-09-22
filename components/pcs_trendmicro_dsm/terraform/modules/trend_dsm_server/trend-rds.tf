resource "aws_db_subnet_group" "trend_dsm_subnet" {
  name                    = "${lower(var.org)}-${lower(var.group)}-${lower(var.environment)}-trendmicro-dsm-subnet-group"
  subnet_ids              = ["${var.data_subnet_ids}"]

  tags {
    Name                  = "Trend Micro DSM Subnet Group"
  }
}

resource "aws_db_instance" "tm_server_rds" {
  name = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSMDB-postgresql-rds"
  allocated_storage       = 10

  storage_type            = "gp2"
  engine                  = "${var.dsm_db_engine}"
  instance_class          = "${var.dsm_db_instance_type}"
  name                    = "${var.dsm_db_instance_name}"
  username                = "${var.dsm_db_username}"
  password                = "${var.dsm_db_password}"
  db_subnet_group_name    = "${aws_db_subnet_group.trend_dsm_subnet.name}"
  vpc_security_group_ids  = [ "${aws_security_group.dsm_rds_access.id}" ]

  multi_az                = "true"

  kms_key_id              = "${var.general_kms}"
  
  storage_encrypted       = "true"

  backup_retention_period = 30
  copy_tags_to_snapshot   = true
  
  skip_final_snapshot     = "true" 
}

resource "consul_keys" "trendmicro_dsm_db" {

  key {
    path                  = "aws/pcs/trendmicro/dsm_db_hostname"
    value                 = "${aws_db_instance.tm_server_rds.address}",
    delete                = true
  }
}
