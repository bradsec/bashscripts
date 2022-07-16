#!/usr/bin/env bash

SCRIPT_SOURCE="github.com/bradsec/bashscripts/officeapps.sh"

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

install_onlyoffice() {
	message INFO "Installing OnlyOffice..."
    message WARN "Downloads for OnlyOffice are over 300MB in size."
    wait_for user_continue
	from_url="https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
	save_file="/tmp/onlyoffice.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
}

install_libreoffice() {
	message INFO "Installing LibreOffice..."
    message WARN "Downloads for LibreOffice are approximately 200MB in size."
    wait_for user_continue
	pkgman install libreoffice
}

# Display a list of menu items for selection
display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install OnlyOffice"
    echo -e "2. Install LibreOffice"
    echo -e "3. Remove OnlyOffice"
    echo -e "4. Remove LibreOffice"
    echo -e "5. Exit\n"
    echo -n "   Enter option [1-5]: "

    while :
    do
		read choice
		case ${choice} in
		1)  clear
			pkgman remove onlyoffice-desktopeditors
			install_onlyoffice
			;;
		2)  clear
			install_libreoffice
			;;
		3)  clear
			pkgman remove onlyoffice-desktopeditors
			;;
		4)  clear
			apt-get remove -y libreoffice*
			pkgman cleanup
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
