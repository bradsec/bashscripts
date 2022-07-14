#!/usr/bin/env bash

SCRIPT_SOURCE="github.com/bradsec/bashscripts/messenger.sh"

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

install_signal() {
	message INFO "Installing Signal..."
	pkgman install apt-transport-https
	fetch_signing_key "packages.signal" "https://updates.signal.org/desktop/apt/keys.asc"
	add_apt_source "packages.signal" "signal.list" "https://updates.signal.org/desktop/apt xenial main"
	pkgman update
	pkgman install signal-desktop
}

install_threema() {
	message INFO "Installing Threema..."
	from_url="https://releases.threema.ch/web-electron/v1/release/Threema-Latest.deb"
	save_file="/tmp/threema.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
}

# Display a list of menu items for selection
display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install Signal"
    echo -e "2. Install Threema"
    echo -e "3. Remove Signal"
    echo -e "4. Remove Threema"
    echo -e "5. Exit\n"
    echo -n "   Enter option [1-5]: "

    while :
    do
		read choice
		case ${choice} in
		1)  clear
			pkgman remove signal-desktop
			run_command rm -f /etc/apt/sources.list.d/signal.list
            pkgman update
			install_signal
			;;
		2)  clear
			pkgman remove threema
			install_threema
			;;
		3)  clear
			pkgman remove signal-desktop
			run_command rm -f /etc/apt/sources.list.d/signal.list
			pkgman update
			;;
		4)  clear
			pkgman remove threema
			;;
		5)  clear
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
