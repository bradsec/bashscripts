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

install_opt_app() {
    local app="${1}"
    message INFOFULL "This script will install ${app} using the latest AppImage."
	message WARNFULL "Any existing ${app} settings or configuration may be lost."
	wait_for user_continue
	# Update packages and install required packages
	message INFO "Checking for required packages..."
	pkgman update
	pkgman install curl wget
    # If available or required install fuse and libfuse
    pkgman install fuse
    pkgman install libfuse
	pkgman remove ${app}
    if [[ "${app}" == "bitwarden" ]]; then
        local app_name="BitWarden"
        local from_url="https://vault.bitwarden.com/download/?app=desktop&platform=linux"
    elif [[ "${app}" == "keepassxc" ]]; then
        local app_name="KeePassXC"
        local from_url="https://github.com$(curl -s https://github.com/keepassxreboot/keepassxc/releases \
        | awk -F"[><]" '{for(i=1;i<=NF;i++){if($i ~ /a href=.*\//){print "<" $i ">"}}}' \
        | grep AppImage -A 1 | awk 'NR==1' | sed -r 's/.*href="([^"]+).*/\1/g')"
    fi
    run_command mkdir -p /opt/${app}
    local save_file="/opt/${app}/${app}.AppImage"
    download_file ${save_file} ${from_url}
    # Download desktop icon
	local from_url="https://raw.githubusercontent.com/bradsec/bashscripts/main/assets/images/${app}-icon.png"
	local save_file="/opt/${app}/${app}-icon.png"
	download_file ${save_file} ${from_url}
    # Modify permissions and links
	run_command sudo chmod 755 /opt/${app}/${app}.AppImage
	run_command sudo chmod 644 /opt/${app}/${app}-icon.png
	run_command ln -sf /opt/${app}/${app}.AppImage /usr/sbin/${app}
    # Config for desktop
    desktop_config="[Desktop Entry]
Name=${app_name}
Exec=/opt/${app}/${app}.AppImage %U
Type=Application
Icon=/opt/${app}/${app}-icon.png
Terminal=false
GenericName=Password Manager
Comment=A secure password manager for all of your devices.
StartupWMClass=${app}
MimeType=x-scheme-handler/${app};
Categories=Utility;Security;"
    # Write config
    write_config_file "${desktop_config}" "/usr/share/applications/${app}.desktop"
    message DONEFULL "${app_name} installed. Use the desktop icon or command ${app} from terminal to launch."
}

display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install Bitwarden (Uses an online vault)"
    echo -e "2. Install KeePassXC (Uses an offline vault)\n"
    echo -e "3. Remove Bitwarden"
    echo -e "4. Remove KeePassXC\n"
    echo -e "5. Exit"
    echo
    echo -n "   Enter option [1-5]: "

    while :
    do
        read choice
        case $choice in
        1)  clear
            install_opt_app bitwarden
            ;;
        2)  clear
            install_opt_app keepassxc
            ;;
        3)  clear
            remove_opt_app bitwarden
            ;;
        4)  clear
            remove_opt_app keepassxc
            ;;
        5)  clear
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