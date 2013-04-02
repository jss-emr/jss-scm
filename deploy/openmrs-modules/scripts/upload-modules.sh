#!/bin/bash

login() {
	curl -i -c /tmp/cookie.txt -d uname=admin -d pw=${1} $OPENMRS_URL/loginServlet > /tmp/login_response.txt	
}

upload_from_local_file(){
	if ! [ -f $1 ]; then
	   echo Error: module file $1 does not exist
	   exit 1
	fi

	curl -i -b /tmp/cookie.txt -F action=upload -F update=true -F moduleFile=\@$1 $OPENMRS_URL/admin/modules/module.list > /tmp/upload_response.txt	

	if grep -q "modules/module.list" "/tmp/upload_response.txt"; then
		rm -rf /tmp/upload_response.txt /tmp/login_response.txt > /dev/null 2>&1
	else 
		echo "Failed to update module. Please check /tmp/upload_response.txt and /tmp/login_response.txt more info"
		exit 1
	fi
}

upload_from_http_url(){
	curl -i -b /tmp/cookie.txt -F action=upload -F download=true -F downloadURL=$1 $OPENMRS_URL/admin/modules/module.list > /tmp/upload_response.txt	
}

upload_module() {
	if [[ $1 =~ http:.* ]];	then
	   upload_from_http_url $1
	else
	   upload_from_local_file $1		
	fi
}

check_args() {
	if [ $# -lt 2 ]; then
	   echo "Usage: $0 admin-password modules"
		 echo "Default OPENMRS_URL is http://localhost:8080/openmrs"
	   exit 1
	fi	
}

assign_defaults () {
	if [ -z $OPENMRS_URL ]; then 
		OPENMRS_URL='http://localhost:8080/openmrs'
	fi	
}

cleanup() {
	rm -rf /tmp/cookie.txt > /dev/null 2>&1	
}

upload_modules() {
	for module in $@
	do
		upload_module $module
	done	
}

_main_() {
	set -e

	check_args $@
	assign_defaults
	login $1
	shift
	upload_modules $@
	cleanup
}

_main_ $@



