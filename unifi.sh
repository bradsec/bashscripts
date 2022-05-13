#!/usr/bin/env bash

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
message INFO "Source: github.com/bradsec/bashscripts/${0}\n"
get_date_time
get_os summary
### END OF REQUIRED FUNCTION ###

install_app() {
    message INFOFULL "Installing Unifi Controller..."
    message WARNFULL "IMPORTANT: Backup/export any existing Unifi controller configurations before running."
    message WARN "Download for Unifi Controller is approximately 170MB."
    wait_for user_continue
    message INFO "Removing any old versions and possible conflicting packages..."
    # Remove any existing unifi installation
    remove_app
    # Unifi controller depends on older packages including mongodb <= 3.6
    message INFO "Adding required repo keys and sources..."
    fetch_keyserver_signing_key "debian-stretch-repo" "keyserver.ubuntu.com" "04EE7237B7D453EC"
    add_apt_source "debian-stretch-repo" "debian-stretch.list" "http://deb.debian.org/debian stretch main"
    fetch_keyserver_signing_key "unifi-repo" "keyserver.ubuntu.com" "06E85760C0A52C50"
    add_apt_source "unifi-repo" "100-ubnt-unifi.list" "https://www.ui.com/downloads/unifi/debian stable ubiquiti" "armhf"
    pkgman update
    # Install required packages
    message INFO "Running check for required packages..."
    pkgman install curl ca-certificates apt-transport-https openjdk-8-jre-headless haveged jsvc
    run_command apt-mark hold openjdk*
    # Install unifi verbose to show working
    message INFO "Running unifi installation with verbose output..."
    apt-get -y install unifi
    message INFO "Reboot required to ensure unifi starts correctly."
    local hostip=$(hostname -I | awk '{print $1}')
    message INFO "After reboot access Unifi in browser at https://${hostip}:8443"
    wait_for user_continue
    run_command /usr/sbin/shutdown -r now
    }


remove_app() {
    message INFOFULL "Removing Unifi Controller..."
    systemctl stop unifi >/dev/null 2>&1 || true
    systemctl stop mongodb >/dev/null 2>&1 || true
    pkgman remove unifi mongodb-org* mongodb* openjdk-8-jre-headless haveged jsvc
    run_command rm -f /etc/apt/sources.list.d/100-ubnt-unifi.list
    run_command rm -f /etc/apt/sources.list.d/debian-stretch.list
    run_command rm -rf /usr/lib/unifi /var/lib/unifi
    run_command rm -f /etc/systemd/system/unifi.service
    run_command rm -rf /var/log/mongodb /var/lib/mongodb
    pkgman cleanup
    pkgman update
    pkgman fix
}


display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Setup Unifi Controller"
    echo -e "2. Remove Unifi Controller\n"
    echo -e "3. Exit"
    echo
    echo -n "   Enter option [1-3]: "

    while :
    do
        read choice
        case $choice in
        1)  clear
            install_app
            ;;
        2)  clear
            remove_app
            ;;
        3)  clear
            exit
            ;;
		*)  clear
			display_menu
            ;;
        esac
        echo
        message DONEFULL "Selection [${choice}] completed."
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