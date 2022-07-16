#!/usr/bin/env bash

SCRIPT_SOURCE="github.com/bradsec/bashscripts/collabapps.sh"

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

install_discord() {
	message INFO "Installing Discord..."
	from_url="https://discord.com/api/download?platform=linux&format=deb"
	save_file="/tmp/discord.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
	pkgman fix
}

install_teams() {
	message INFO "Installing Microsoft Teams..."
	from_url="https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x409&culture=en-us&country=US"
	save_file="/tmp/teams.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
	pkgman fix
}

install_slack() {
	message INFO "Installing Slack..."
	# Two fixes below for missing packages in Debian Bullseye
	message INFO "Installing requiried Debian packages..."
	from_url="http://ftp.mx.debian.org/debian/pool/main/libi/libindicator/libindicator3-7_0.5.0-3+b1_amd64.deb"
	save_file="/tmp/libind.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
	from_url="http://ftp.mx.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb"
	save_file="/tmp/libapp.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
	# Fetch latest Slack version
	message INFO "Fetching latest Slack .deb package..."
	slack_version="$(curl -s https://slack.com/downloads/linux | grep -o '\Version\+ [0-9].2[0-9]....' | awk '{print $2}')"
	from_url="https://downloads.slack-edge.com/releases/linux/${slack_version}/prod/x64/slack-desktop-${slack_version}-amd64.deb"
	save_file="/tmp/slack.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
	pkgman fix
}

# Display a list of menu items for selection
display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install Discord"
	echo -e "2. Install Slack"
	echo -e "3. Install Microsoft Teams\n"
    echo -e "4. Remove Discord"
    echo -e "5. Remove Slack"
	echo -e "6. Remove Microsoft Teams\n"
    echo -e "7. Exit\n"
    echo -n "   Enter option [1-7]: "

    while :
    do
		read choice
		case ${choice} in
		1)  clear
			pkgman remove discord
			install_discord
			;;
		2)  clear
			pkgman remove slack-desktop
			install_slack
			;;
		3)  clear
			pkgman remove teams
			install_teams
			;;
		4)  clear
			pkgman remove discord
			;;
		5)  clear
			pkgman remove slack-desktop
			;;
		6)  clear
			pkgman remove teams
			;;
		7)  clear
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
