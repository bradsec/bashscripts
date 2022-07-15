#!/usr/bin/env bash

SCRIPT_SOURCE="github.com/bradsec/bashscripts/goapps.sh"

#### START OF REQUIRED INFORMATION FOR IMPORTING BASH TEMPLATES ###
TEMPLATES_REQUIRED="generic.tmpl.sh debian.tmpl.sh"

# Imports bash script functions from a local template or the github hosted template file.
import_templates() {
	local templates_remote="https://raw.githubusercontent.com/bradsec/bashscripts/main/templates/"
	# Set templates_local to relative path to clone repo.
	local templates_local="./templates/"
	for tmpl in "${@}"; do
		if [[ -f "${templates_local}${tmpl}" ]]; then
			echo -e "Importing local template: ${tmpl}"
			eval "$(cat ${templates_local}${tmpl})" || echo -e "An error occurred in template eval."
		else
			echo -e "Importing remote template: ${tmpl}"
			if template=$(wget -qO- ${templates_remote}${tmpl}); then
				eval "${template}" || echo -e "An error occurred in template eval."
			else
			message fail "Unable to import required template: \"${tmpl}\". Exiting..."
			exit 1
			fi
		fi
	done
}

import_templates ${TEMPLATES_REQUIRED}
clear
message INFO "Source: ${SCRIPT_SOURCE}\n"
get_date_time
get_os summary
### END OF REQUIRED FUNCTION ###

install_golang() {
	message INFO "Installing Go Programming Language..."
	run_command rm -rf /usr/local/go
	from_url="https://go.dev$(curl -s https://go.dev/dl/ | \
	grep linux | grep $(dpkg --print-architecture) -A 0 | sed -r 's/.*href="([^"]+).*/\1/g' | awk 'NR==1')"
	save_file="/tmp/golang.tar.gz"
	download_file ${save_file} ${from_url}
	run_command tar -C /usr/local -xzf ${save_file}
	echo "export PATH=/usr/local/go/bin:${PATH}" | tee /etc/profile.d/go.sh >/dev/null 2>&1
	run_command source /etc/profile.d/go.sh
	go_version="$(go version)"
	message DONEFULL "${go_version} installed."
}

# Display a list of menu items for selection
display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install Go (Golang) Programming Language"
    echo -e "2. Remove Go"
    echo -e "3. Exit\n"
    echo -n "   Enter option [1-3]: "

    while :
    do
		read choice
		case ${choice} in
		1)  clear
			install_golang
			;;
		2)  clear
			run_command rm -rf /usr/local/go
			run_command rm /etc/profile.d/go.sh
			;;
		3)  clear
			exit
			;;
		*)  clear
			display_menu
            ;;
		esac
		echo -e "\nSelection [${choice}] completed."
		wait_for user_anykey
		clear
		display_menu
    done
}

# Main function
main() {
	check_superuser
    display_menu
}

main "${@}"
