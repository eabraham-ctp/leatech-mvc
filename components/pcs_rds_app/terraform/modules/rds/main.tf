provider "aws" {
  region = "${var.region}"
}


resource "aws_db_subnet_group" "rds_subnet" {
  name                    = "${lower(var.org)}-${lower(var.environment)}-${lower(var.app_name)}-rds-subnet"
  subnet_ids              = ["${var.subnet_ids}"]
  tags                    = "${merge(var.default_tags, map("Name", format("%s-%s-%s-rds-subnet", var.org, var.environment, var.app_name)))}"
}

resource "aws_db_instance" "rds" {
  allocated_storage       = "${var.allocated_storage}"
  storage_type            = "${length(var.storage_type) > 0 ? var.storage_type : "gp2"}"
  engine                  = "${length(var.engine) > 0 ? var.engine : "postgres"}"
  instance_class          = "${var.instance_type}"
  identifier              = "${length(var.db_identifier) > 0 ? var.db_identifier : var.db_name}"
  name                    = "${length(var.db_name) > 0 ? var.db_name : var.app_name}"
  username                = "${var.username}"
  password                = "${var.password}"
  db_subnet_group_name    = "${aws_db_subnet_group.rds_subnet.name}"
  vpc_security_group_ids  = ["${aws_security_group.rds_sg.id}"]
  multi_az                = "${var.multi_az}"
  kms_key_id              = "${var.general_kms}"
  storage_encrypted       = "true"
  backup_retention_period = "${var.db_backups}"
  copy_tags_to_snapshot   = "true"
  skip_final_snapshot     = "${var.skip_final_snapshot}"
  tags                    = "${merge(var.default_tags, map("Name", format("%s-%s-%s-RDS", var.org, var.environment, var.app_name)))}"
}
