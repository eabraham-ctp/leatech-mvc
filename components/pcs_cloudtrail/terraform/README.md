
### Initialize environment
1. Start consul agent or use the one from AWS
  4.1 consul agent -bootstrap-expect=1 -server -data-dir=$HOME/consul-data -ui -bind=127.0.0.1 -client=0.0.0.0 &
1. terraform env new $TF_VAR_environment
1. terraform env select $TF_VAR_environment
1. cd bootstrap/build
1. ./bootstrap.sh -o=SVBRND -g=PCS -e=DEV -c=cloudtrail -a -m=plan


