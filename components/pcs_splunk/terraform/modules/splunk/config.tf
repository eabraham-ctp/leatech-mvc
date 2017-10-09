data "aws_region" "current" {current=true}
data "aws_caller_identity" "current" {}

data "template_file" "account_conf" {
  template = <<EOF
[${aws_iam_role.splunk.name}]
  category = 1
  iam = 1
EOF
}

data "template_file" "inputs_conf" {
  template = <<EOF
[aws_cloudtrail://${aws_iam_role.splunk.name}:${data.aws_region.current.name}:${var.sqs_queue == "" ? "" : element(split(":", var.sqs_queue),5)}:${data.aws_caller_identity.current.account_id}]
  aws_account = ${aws_iam_role.splunk.name}
  aws_region = ${data.aws_region.current.name}
  exclude_describe_events = True
  index = main
  interval = 30
  remove_files_when_done = False
  sourcetype = aws:cloudtrail
  sqs_queue = ${var.sqs_queue == "" ? "" : element(split(":", var.sqs_queue),5)}
EOF
}

data "template_file" "serverclass_conf" {
  template = <<EOF
[serverClass:sc_master]
stateOnClient = "noop"
whitelist.0 = ${aws_instance.master.private_ip}

[serverClass:sc_searchhead]
whitelist.0 = *
blacklist.0 = ${aws_instance.master.private_ip}
EOF
}

data "template_file" "web_conf" {
  template = <<EOF
[settings]
httpport        = ${var.httpport}
management_port    = 127.0.0.1:${var.management_port}
EOF
}

data "template_file" "deployer_conf" {
  template = <<EOF
[shclustering]
pass4SymmKey  = ${var.pass4SymmKey}
shcluster_label = splunk_searchead_cluster
EOF
}

data "template_file" "forwarder_conf" {
  template = <<EOF
[diskUsage]
minFreeSpace = 2000

[kvstore]
disabled = true

[general]
pass4SymmKey = ${var.pass4SymmKey}
EOF
}

data "template_file" "deploymentclient_conf" {
  template    = "${file("${path.module}/deployment.tpl")}"
  vars     {
    management_port        = "${var.management_port}"
    deploymentserver_ip = "${var.deploymentserver_ip}"
  }
}

data "template_file" "server_conf_indexer" {
  template = <<EOF
[replication_port://${var.replication_port}]

[diskUsage]
minFreeSpace = 2000

[clustering]
mode = slave
master_uri = https://${aws_instance.master.private_ip}:${var.management_port}
pass4SymmKey = ${var.pass4SymmKey}

EOF
}

data "template_file" "server_conf_searchhead" {
  template = <<EOF
[replication_port://${var.replication_port}]

[diskUsage]
minFreeSpace = 2000

[clustering]
mode = searchhead
master_uri = https://${aws_instance.master.private_ip}:${var.management_port}
pass4SymmKey = ${var.pass4SymmKey}

[shclustering]
pass4SymmKey  = ${var.pass4SymmKey}
shcluster_label = splunk_searchead_cluster
conf_deploy_fetch_url = https://${aws_instance.master.private_ip}:${var.management_port}
disabled = 0
replication_factor = ${var.search_factor}
EOF
}

data "template_file" "server_conf_master" {
  template = <<EOF
[clustering]
mode = master
replication_factor = ${var.replication_factor}
search_factor = ${var.search_factor}
pass4SymmKey = ${var.pass4SymmKey}
EOF
}

data "template_file" "user_data_deploymentserver" {
  template    = "${file("${path.module}/user_data.tpl")}"
  vars    {
    inputs_conf                     = ""
    account_conf                    = ""
    deployer_conf                   = ""
    deploymentclient_conf_content   = ""
    server_conf_content             = ""
    serverclass_conf_content        = "${data.template_file.serverclass_conf.rendered}"
    web_conf_content                = "${data.template_file.web_conf.rendered}"
    indexerASG                      = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-ASG"
    searchASG                       = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-ASG"
    role                            = "deploymentserver"
    secret                          = "${var.secret}"
    ui_password                     = "${var.ui_password}"
  }
}

data "template_file" "user_data_searchhead" {
  template    = "${file("${path.module}/user_data.tpl")}"
  vars    {
    inputs_conf                     = ""
    account_conf                    = ""
    deployer_conf                   = ""
    deploymentclient_conf_content   = "${data.template_file.deploymentclient_conf.rendered}"
    server_conf_content             = "${data.template_file.server_conf_searchhead.rendered}"
    serverclass_conf_content        = ""
    web_conf_content                = "${data.template_file.web_conf.rendered}"
    indexerASG                      = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-ASG"
    searchASG                       = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-ASG"
    role                            = "searchhead"
    secret                          = "${var.secret}"
    ui_password                     = "${var.ui_password}"
  }
}

data "template_file" "user_data_indexer" {
  template    = "${file("${path.module}/user_data.tpl")}"
  vars    {
    inputs_conf                     = ""
    account_conf                    = ""
    deployer_conf                   = ""
    deploymentclient_conf_content   = ""
    server_conf_content             = "${data.template_file.server_conf_indexer.rendered}"
    serverclass_conf_content        = ""
    web_conf_content                = "${data.template_file.web_conf.rendered}"
    indexerASG                      = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-ASG"
    searchASG                       = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-ASG"
    role                            = "indexer"
    ui_password                     = "${var.ui_password}"
    secret                          = "${var.secret}"
  }
}

data "template_file" "user_data_master" {
  template    = "${file("${path.module}/user_data.tpl")}"
  vars    {
    inputs_conf                     = ""
    account_conf                    = ""
    deployer_conf                   = "${data.template_file.deployer_conf.rendered}"
    deploymentclient_conf_content   = "${data.template_file.deploymentclient_conf.rendered}"
    server_conf_content             = "${data.template_file.server_conf_master.rendered}"
    serverclass_conf_content        = ""
    web_conf_content                = "${data.template_file.web_conf.rendered}"
    indexerASG                      = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-ASG"
    searchASG                       = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-ASG"
    role                            = "master"
    secret                          = "${var.secret}"
    ui_password                     = "${var.ui_password}"
  }
}

data "template_file" "user_data_forwarder" {
  template    = "${file("${path.module}/user_data.tpl")}"
  vars    {
    inputs_conf                     = "${data.template_file.inputs_conf.rendered}"
    account_conf                    = "${data.template_file.account_conf.rendered}"
    deployer_conf                   = ""
    deploymentclient_conf_content   = ""
    server_conf_content             = "${data.template_file.forwarder_conf.rendered}"
    serverclass_conf_content        = ""
    web_conf_content                = "${data.template_file.web_conf.rendered}"
    indexerASG                      = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-ASG"
    searchASG                       = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-ASG"
    role                            = "forwarder"
    secret                          = "${var.secret}"
    ui_password                     = "${var.ui_password}"
  }
}
