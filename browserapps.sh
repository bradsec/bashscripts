#!/usr/bin/env bash

SCRIPT_SOURCE="github.com/bradsec/bashscripts/browserapps.sh"

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

install_firefox() {
	message INFOFULL "This will install the latest Firefox browser version."
	message WARNFULL "This script will attempt to remove any existing installations of Firefox including Firefox ESR."
	message WARNFULL "Existing Firefox settings and preferences will be lost."
	wait_for user_continue
    # Remove any previous firefox packages
    pkgman remove firefox-esr
    pkgman remove firefox
	# Add fix for missing XPCOM error libdbus-glib-1.so.2 cannot open shared object
	apt-get -y install libdbus-glib-1-2 || true
	# Download latest linux 64 version
	local from_url="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
	local save_file="/tmp/firefox.tar.bz2"
	download_file ${save_file} ${from_url}
    # Extract files to /opt/
    run_command tar -xvf ${save_file} --directory /opt/
    run_command sudo ln -sf /opt/firefox/firefox /usr/sbin/firefox
    # Write desktop icon configuration file
	local firefox_config="[Desktop Entry]
	Name=Firefox
	Comment=Browse the World Wide Web
	GenericName=Web Browser
	X-GNOME-FullName=Firefox Web Browser
	Exec=/opt/firefox/firefox %u
	Terminal=false
	X-MultipleArgs=false
	Type=Application
	Icon=/opt/firefox/browser/chrome/icons/default/default48.png
	Categories=Network;WebBrowser;
	MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
	StartupWMClass=Firefox
	StartupNotify=true"
    write_config_file "${firefox_config}" "/usr/share/applications/firefox.desktop"
    run_command rm ${save_file}
	message DONEFULL "Firefox installed."
}

install_brave() {
	message INFOFULL "This will install the latest Brave browser version."
	message WARNFULL "This script will attempt to remove any existing installations of Brave."
	message WARNFULL "Existing Brave settings and preferences will be lost."
	wait_for user_continue
	# Check requirements
	pkgman install apt-transport-https curl
	# Fetch signing keys and add apt source
	fetch_signing_key "brave-browser-archive" "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
	add_apt_source "brave-browser-archive" "brave-browser.list" "https://brave-browser-apt-release.s3.brave.com/ stable main"
	# Update packages and install
	pkgman update
	pkgman install brave-browser
	message DONEFULL "Brave installed."
}

install_tor_browser(){
	message INFOFULL "This will install the latest TOR-Browser version."
	pkgman install curl
	tor_link="https://www.torproject.org$(curl -s https://www.torproject.org/download/ | \
	grep linux | sed -r 's/.*href="([^"]+).*/\1/g' | awk 'NR==1')"
	local from_url="${tor_link}"
	local save_file="/tmp/torbrowser.tar.xz"
	download_file ${save_file} ${from_url}
	run_command tar -xvJf ${save_file} --directory /opt/
	pkg_path="/opt/$(ls /opt/ | grep tor-browser)"
	run_command chown -R $(get_user):$(get_user) ${pkg_path}
	run_command chmod 755 ${pkg_path}/start-tor-browser.desktop
	run_command ln -sf ${pkg_path}/start-tor-browser.desktop /usr/sbin/tor-browser
	run_command cd ${pkg_path}
	su -c './start-tor-browser.desktop --register-app' $(logname) >/dev/null 2>&1
	message DONEFULL "TOR-Browser installed."
}

install_chrome() {
	message INFO "Installing Google Chrome..."
	pkgman remove google-chrome-stable
	from_url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
	save_file="/tmp/chrome.deb"
	download_file ${save_file} ${from_url}
	pkgman install ${save_file}
	message DONEFULL "Chrome installed."
}


display_menu () {
	echo
    echo -e "=============="                         
    echo -e " Menu Options "
    echo -e "=============="
	echo
    echo -e "1. Install Firefox"
	echo -e "2. Install Google Chrome"
    echo -e "3. Install Brave"
	echo -e "4. Install TOR Browser\n"
    echo -e "5. Remove Firefox"
	echo -e "6. Remove Google Chrome"
    echo -e "7. Remove Brave"
	echo -e "8. Remove TOR Browser\n"
    echo -e "9. Exit"
    echo
    echo -n "   Enter option [1-9]: "

    while :
    do
        read choice
        case $choice in
        1)  clear
            install_firefox
            ;;
        2)  clear
            install_chrome
            ;;
        3)  clear
            install_brave
            ;;
        4)  clear
            install_tor_browser
            ;;
        5)  clear
            remove_opt_app firefox
            ;;
        6)  clear
            pkgman remove google-chrome-stable
			pkgman update
			pkgman cleanup
            ;;
        7)  clear
            pkgman remove brave-browser
			run_command rm -f /etc/apt/sources.list.d/brave-browser*
			pkgman update
			pkgman cleanup
            ;;
		8)  clear
            remove_opt_app tor-browser
            ;;
        9)  clear
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


main() {
	check_superuser
	display_menu
}
main "${@}"