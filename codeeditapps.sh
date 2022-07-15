#!/usr/bin/env bash

SCRIPT_SOURCE="github.com/bradsec/bashscripts/codeeditapps.sh"

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

install_sublimetext3() {
	message INFO "Installing Sublime-Text 3..."
	from_url="https://download.sublimetext.com/sublime-text_build-3211_$(dpkg --print-architecture).deb"
	save_file="/tmp/sublimetext3.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
}

install_sublimetext4() {
	message INFO "Installing Sublime-Text 4..."
	pkgman install apt-transport-https
	fetch_signing_key "packages.sublimehq" "https://download.sublimetext.com/sublimehq-pub.gpg"
	add_apt_source "packages.sublimehq" "sublimetext.list" "https://download.sublimetext.com/ apt/stable/"
	pkgman update
	pkgman install sublime-text
}

install_vscodium() {
	message INFO "Installing VSCodium..."
	from_url="https://github.com$(curl -s https://github.com/VSCodium/vscodium/releases \
	| awk -F"[><]" '{for(i=1;i<=NF;i++){if($i ~ /a href=.*\//){print "<" $i ">"}}}' \
	| grep $(dpkg --print-architecture) -A 0 | awk 'NR==1' | sed -r 's/.*href="([^"]+).*/\1/g')"
	save_file="/tmp/codium.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
}

install_vscode() {
	message INFO "Installing Microsoft Visual Studio Code..."
	pkgman install curl wget gpg software-properties-common apt-transport-https
	fetch_signing_key "packages.microsoft" "https://packages.microsoft.com/keys/microsoft.asc"
	add_apt_source "packages.microsoft" "vscode.list" "https://packages.microsoft.com/repos/code stable main"
	pkgman update
	pkgman install code
}

# Display a list of menu items for selection
display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install Sublime-Text 3"
    echo -e "2. Install Sublime-Text 4"
    echo -e "3. Install VS Codium"
    echo -e "4. Install VS Code\n"
    echo -e "5. Remove Sublime-Text"
    echo -e "6. Remove VS Codium"
    echo -e "7. Remove VS Code\n"
    echo -e "8. Exit\n"
    echo -n "   Enter option [1-8]: "

    while :
    do
		read choice
		case ${choice} in
		1)  clear
			pkgman remove sublime-text
			run_command rm -f /etc/apt/sources.list.d/sublimetext.list
			install_sublimetext3
			;;
		2)  clear
			pkgman remove sublime-text
			install_sublimetext4
			;;
		3)  clear
			install_vscodium
			;;
		4)  clear
			install_vscode
			;;
		5)  clear
			pkgman remove sublime-text
			run_command rm -f /etc/apt/sources.list.d/sublimetext.list
			pkgman update
			;;
		6)  clear
			pkgman remove codium
			;;
		7)  clear
			pkgman remove code
			run_command rm -f /etc/apt/sources.list.d/vscode.list
			pkgman update
			;;
		8)  clear
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