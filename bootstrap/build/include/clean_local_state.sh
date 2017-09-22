#!/bin/bash
function clean_local_state () {
		BANNER "Removing local state files and module caches"
		rm -rf $COMPONENTS_DIR/*/terraform/terraform.tfstate*
	    rm -rf $COMPONENTS_DIR/*/terraform/.terraform
}

