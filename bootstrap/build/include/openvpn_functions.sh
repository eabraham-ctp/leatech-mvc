#!/bin/bash

function connect_to_openvpn () {

	echo "check if the a client daemon already running:"
	OVPN_PID=$(ps aux | grep "${OPENVPN_BINARY} --daemon --writepid"|grep -v grep| awk '{print $2}')
	if [ ! -z $OVPN_PID ]; then
		echo "Openvpn client already running, disconnecting. (killing process $OVPN_PID)"
		$SUDO_BINARY sudo pkill -SIGTERM -f "${SUDO_BINARY} ${OPENVPN_BINARY} --daemon --writepid ${OPENVPN_PID_FILE} --config ${OPENVPN_CONFIG_FILE} --log /var/log/openvpn.log" 
		$SUDO_BINARY kill -SIGTERM $OVPN_PID
		$SUDO_BINARY rm $OPENVPN_PID_FILE
		$SUDO_BINARY touch $OPENVPN_PID_FILE

		sleep 5
		echo "Openvpn log:"
		$SUDO_BINARY tail /var/log/openvpn.log | grep "process exiting"
		pause "Press enter key to continue"
	fi
	echo -e "Connecting to OpenVPN using $OPENVPN_CONFIG_FILE ,  PID file: ${OPENVPN_PID_FILE}"
	$SUDO_BINARY rm ${OPENVPN_PID_FILE}
	$SUDO_BINARY touch ${OPENVPN_PID_FILE}
	if [ $VERBOSE ]; then
		echo "running"
		echo "${SUDO_BINARY} ${OPENVPN_BINARY} --daemon --writepid ${OPENVPN_PID_FILE} --config ${OPENVPN_CONFIG_FILE} --log /var/log/openvpn.log" #TECHDEBT we declare it and call it 
	fi
	${SUDO_BINARY} ${OPENVPN_BINARY} --daemon --writepid ${OPENVPN_PID_FILE} --config ${OPENVPN_CONFIG_FILE} --log /var/log/openvpn.log #TECHDEBT we don't need to use a root directory
	sleep 5
	if $VERBOSE; then
		$SUDO_BINARY tail /var/log/openvpn.log #TECHDEBT delare once
	fi
	ps -ef | grep -v grep | grep " $(cat ${OPENVPN_PID_FILE})" > /dev/null
	if [ $? -eq "0" ]; then
		echo "OpenVPN connected"
	else
		echo "OpenVPN connection failed"
		exit
	fi
	echo -e "Open vpn initiated, pid: $(cat ${OPENVPN_PID_FILE})"
}

function create_vpn_config_file () {
	cd $SCRIPT_DIR
	# create OpenVPN config file
	echo -e "Creating openvpn client config file for user ${TF_VAR_openvpn_user}"
	cat << EOF > $SCRIPT_DIR/ovpn_auth.txt
${TF_VAR_openvpn_user}
${TF_VAR_openvpn_password}
EOF

	# Manually set up the OpenVPN config file.
	## <TODO> Setup openvpn AMI with baked CA
	echo "In order to connect to the openvpn we need to download the config file"
	echo
	echo "login to https://${OPENVPN_SERVER_IP}"
	echo "use the user ${TF_VAR_openvpn_user}"
	echo "Select the \"Yourself (user-locked profile)\" option"
	echo "Save the file to ${SCRIPT_DIR}/${OPENVPN_CONFIG_FILE}"
	echo 
	echo "Did you downlad the file? (y/N)"
	read VERIFY
	if [ "$VERIFY" != "y" ] && [ "$VERIFY" != "Y" ]; then
	  echo "Exiting with no changes"
	  exit 0
	else
	  cat $OPENVPN_CONFIG_FILE|grep "auth-user-pass ovpn_auth.txt" >> /dev/null
	  if [[ $? -eq 1 ]]; then
	  	echo "auth-user-pass ovpn_auth.txt" >> $OPENVPN_CONFIG_FILE
	  fi
	fi
}

function disconnect_from_openvpn () {
if [ ! -z "$1" ]; then
	echo "Stopping proccess $1"
	$SUDO_BINARY kill $1
else
	echo Disconnecting from openvpn
	$SUDO_BINARY sudo pkill -SIGTERM -f "${SUDO_BINARY} ${OPENVPN_BINARY} --daemon --writepid ${OPENVPN_PID_FILE} --config ${OPENVPN_CONFIG_FILE} --log /var/log/openvpn.log"
fi

if $VERBOSE ; then
	$SUDO_BINARY tail /var/log/openvpn.log
fi
}