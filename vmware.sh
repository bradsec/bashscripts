#!/usr/bin/env bash

#### START OF REQUIRED INFORMATION FOR IMPORTING BASH TEMPLATES ###
TEMPLATES_REQUIRED="generic.tmpl.sh debian.tmpl.sh"
SCRIPT_NAME="vmware.sh"

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
message INFO "Source: github.com/bradsec/bashscripts/${SCRIPT_NAME}\n"
get_date_time
get_os summary
### END OF REQUIRED FUNCTION ###

# Initial setup prerequisites
initial_setup() {
    message INFO "Running initial setup and checking for required packages..."
    pkgman update
    pkgman install wget curl gcc build-essential linux-headers-$(uname -r)
}

# Function to get latest modules release download link
get_vmware_mod_link() {
    get_html=$(curl -s https://github.com/mkubecek/vmware-host-modules/tags)
    grep -m1 -o '/mkubecek/vmware-host-modules/archive/refs/tags/*[a-z]\+[^>"]*.tar.gz' <<<${get_html}
}

# Install function
vmware_install() {
    local app="${1}"
    message WARN "Downloads for VMWare products are over 500MB in size."
    wait_for user_continue
    message INFO "Installing VMWare ${app}..."
    dload_url="https://www.vmware.com/go/get${app}-linux"
    message INFO "Fetching latest version of VMWare ${app}..."
    vmware_filepath="/tmp/vmware_${app}.bundle"
    if ! [[ -f "{vmware_filepath}" ]]; then
        download_file ${vmware_filepath} ${dload_url}
    fi
    message INFO "Running VMWare installer ${vmware_filepath}..."
    run_command chmod a+x ${vmware_filepath}
    run_command ${vmware_filepath}
    message INFO "Download and install latest vmware-host-modules..."
    dload_url="https://github.com/$(get_vmware_mod_link)"
    save_file="/tmp/vmwarehostmods.tar.gz"
    download_file ${save_file} ${dload_url}
    run_command cd /tmp
    run_command tar -xvf ${save_file}
    extract_dir=$(ls | grep -m1 vmware-host-modules)
    run_command cd ${extract_dir}
    run_command tar -cf vmmon.tar vmmon-only
    run_command tar -cf vmnet.tar vmnet-only
    run_command cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/
    message INFO "Installing required VMWare modules..."
    run_command vmware-modconfig --console --install-all
    message DONE "Installation of VMWare ${app} completed."
}

# Uninstall function
vmware_uninstall() {
    local app="${1}"
    message INFO "Uninstalling VMWare ${app}..."
    if ! [[ -x "$(command -v vmware-installer -u vmware-${app})" ]]; then
        message INFO "VMWare ${app} not installed"
    else
        vmware-installer -u vmware-${app}
    fi
}

display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install VMWare Workstation"
    echo -e "2. Install VMWare Player\n"
    echo -e "3. Uninstall VMWare Workstation"
    echo -e "4. Uninstall VMWare Player\n"
    echo -e "5. Exit"
    echo
    echo -n "   Enter option [1-5]: "

    while :
    do
        read choice
        case $choice in
        1)  clear
            initial_setup
            vmware_install workstation
            ;;
        2)  clear
            initial_setup
            vmware_install player
            ;;
        3)  clear
            vmware_uninstall workstation
            ;;
        4)  clear
            vmware_uninstall player
            ;;
        5)  clear
            exit
            ;;
		*)  clear
			display_menu
            ;;        
        esac
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