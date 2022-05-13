#!/usr/bin/env bash

# debian.sh
# Functions/commands specific to Debian based systems.
# Requires: generic.sh template to be loaded first.

TEMPLATE_NAME="DEBIAN"

# Debian apt package related functions
# Example usage: pkgman install curl wget htop nmap
pkgman() {
	for pkg in ${@:2}; do
        local snapinstalled=false
        local appinstalled=false

        task INFO "Checking for package: ${pkg}..."
        if [[ $(command -v snap) ]] >/dev/null 2>&1; then
            if [[ $(snap list ${pkg} | grep -wc "\b${pkg}\b") == "1" ]] &>/dev/null; then
                task PASSINFO "Found snap installation of package: ${pkg}"
                snapinstalled=true
            else
                task PASS
                snapinstalled=false
            fi
        fi

        if [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
            task PASSINFO "Found apt installation of package: ${pkg}"
			aptinstalled=true
		else
            task PASS
			aptinstalled=false
		fi

        if [[ ${snapinstalled} == false ]] && [[ ${aptinstalled} == false ]]; then
            task PASSINFO "Package: ${pkg} is not installed."
        fi


        case ${1} in

			install)
                if [[ ${snapinstalled} == false ]] && [[ ${aptinstalled} == false ]]; then
                    # Fix any partially run package installs.
                    #run_command "dpkg --configure -a"
                    message INFO "Attempting to install ${pkg}..."
                    if [[ "${pkg}" == *.deb ]]; then
                        run_command dpkg -i "${pkg}"
                    else
                        run_command apt-get -y install "${pkg}"
                    fi
                    if [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
                        message DONE "Successfully installed package: ${pkg}."
                    fi
                fi
            ;;
			remove)
                if [[ ${snapinstalled} == true ]]; then
                    run_command snap remove "${pkg}"
                    if ! [[ $(snap list ${pkg} | grep -wc "\b${pkg}\b") == "1" ]] &>/dev/null; then
                        message DONE "Successfully removed snap package: ${pkg}."
                    fi
                    continue
                elif [[ ${aptinstalled} == true ]]; then
                    run_command apt-get -y remove "${pkg}"
                    if ! [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
                        message DONE "Successfully removed apt package: ${pkg}."
                    fi
                fi
            ;;
            purge)
                if [[ ${aptinstalled} == true ]]; then
                    run_command apt-get -y purge "${pkg}"
                    if ! [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
                        message DONE "Successfully removed apt package: ${pkg}."
                    fi
                fi
            ;;
            find)
                if [[ $(apt-cache search --names-only "${pkg}" | grep ^${pkg} | wc -l) == "1" ]]; then
                    pkg_match=$(dpkg --get-selections | grep ^${pkg} | sed 's/\s.*$//')
                    echo ${pkg_match}
                fi
            ;;
            size)
                if [[ $(apt-cache --no-all-versions show ${pkg} | grep '^Size: ' | wc -l) == "1" ]]; then
                    pkg_raw_size=$(apt-cache --no-all-versions show ${pkg} | grep '^Size: ' | awk '{print $2}')
                    pkg_size="$(echo ${pkg_raw_size} | numfmt --to=iec | xargs)"
                    echo ${pkg_size}
                fi
            ;;
	 		*) message FAIL "Invalid pkgman() function usage."
             ;;
		    esac
	done

    if [[ -z ${2} ]]; then
            case ${1} in 

            update)
			    run_command apt-get update -y
            ;;
			upgrade)
                run_command apt-get -y upgrade
            ;;
			cleanup)
                run_command apt-get -y autoclean
                run_command apt-get -y autoremove
            ;;
            fix)
                run_command apt-get -y --fix-broken install
            ;;
            esac
    fi
}

# Remove an application installed in /opt/ path
# Will also look for any associated icons.
remove_opt_app() {
    local app="${1}"
    if [[ -z "${app}" ]]; then
        message FAIL "No /opt/ applications has been specified."
        message INFO "Usage: remove_opt_app app name"
        exit 1
    fi
    message INFO "Removing ${app} from /opt directory..."
    message WARNFULL "This will delete all files and directories for ${app} found in /opt/..."
    wait_for user_continue

    app_loc_1="/opt/${app}"

    if [[ $(ls /opt/ | grep ${app}) ]] &>/dev/null; then
        app_loc_2="/opt/$(ls /opt/ | grep ${app})"
    fi

	if [[ "${app_loc_1}" != "/opt/" ]] && [[ -d "${app_loc_1}" ]]; then
		run_command rm -rf ${app_loc_1}
	elif [[ "${app_loc_2}" != "/opt/" ]] && [[ -d "${app_loc_2}" ]]; then
        message INFO "Found possible match in /opt: ${app_loc_2}"
        read -r -p "[${GREEN}USER${RESET}] Delete directory and contents (y/N)?${RESET} " response
        if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
            run_command rm -rf ${app_loc_2}
        else
            message INFO "Skipping..."
        fi
	else
		message INFO "No package found for ${app}."
	fi

	icon_loc_1="/usr/share/applications/${app}.desktop"

    if [[ $(ls /usr/share/applications/ | grep ${app}) ]] &>/dev/null; then
	    icon_loc_2="/usr/share/applications/$(ls /usr/share/applications/ | grep ${app})"
    fi

    if [[ $(ls /home/$(logname)/.local/share/applications/ | grep ${app}) ]] &>/dev/null; then
	    icon_loc_3="/home/$(logname)/.local/share/applications/$(ls /home/$(logname)/.local/share/applications/ | grep ${app})"
    fi

	if [[ "${icon_loc_1}" != "/usr/share/applications/" ]] && [[ -f "${icon_loc_1}" ]]; then
		run_command rm -f ${icon_loc_1}
	elif [[ "${icon_loc_2}" != "/usr/share/applications/" ]] && [[ -f "${icon_loc_2}" ]]; then
        message INFO "Found possible icon match to remove: ${icon_loc_2}"
        read -r -p "[${GREEN}USER${RESET}] Delete this file (y/N)?${RESET} " response
        if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
            run_command rm -f ${icon_loc_2}
        else
            message INFO "Skipping..."
        fi
	elif [[ "${icon_loc_3}" != "/home/$(logname)/.local/share/applications/" ]] && [[ -f "${icon_loc_3}" ]]; then
        message INFO "Found possible icon match to remove: ${icon_loc_3}"
        read -r -p "[${GREEN}USER${RESET}] Delete this file (y/N)?${RESET} " response
        if [[ ${response} == "y" ]] || [[ ${response} == "Y" ]]; then
            run_command rm -f ${icon_loc_3}
        else
            message INFO "Skipping..."
        fi
	else
		message INFO "No desktop icon found for ${app}."
	fi
}

# Function to check if a service is active will return green tick or red cross.
is_active() {
    if [[ $(systemctl is-active "$1") == "active" ]] &>/dev/null; then
        message INFO "The service for ${1} is active."
    else
        message WARN "The service for ${1} is not active."
    fi
}

# Add apt source with signing key to /etc/apt/source.list.d/${repo_name}.list
# Usage 1: add_apt_source "repo_key_name" "repo_list_file.list" "https://validsourceforepo.com stable main"
# Usage 2: add_apt_source "repo_key_name" "repo_list_file.list" "https://validsourceforepo.com stable main" "arm64"
add_apt_source() {
	repo_key=${1}
	repo_list_file=${2}
	repo_source=${3}
    repo_arch=${4}
    # If custom repo_arch is not set get system arch using dpkg --print-architecture
    [[ -z "${repo_arch}" ]] && os_arch="$(dpkg --print-architecture)" || os_arch="${4}"
	message INFO "Adding repo apt source..."
    message INFO "SRC-FILE: /etc/apt/sources.list.d/${repo_list_file}"
    message INFO "SRC-TEXT: deb [arch=${os_arch} signed-by=/usr/share/keyrings/${repo_key}-keyring.gpg] ${repo_source}"
	echo "deb [arch=${os_arch} signed-by=/usr/share/keyrings/${repo_key}-keyring.gpg] ${repo_source}" \
	| sudo tee /etc/apt/sources.list.d/${repo_list_file} &>/dev/null
}

# Fetch repo signing key, determine if ascii-armored, write key to /usr/share/keyrings/${key_name}-archive-keyring.gpg
# Usage: fetch_signing_key  "new_key_name" "https://validkeyurl.com/keyname-pub.gpg"
fetch_signing_key() {
    pkgman install gpg
	mkdir -p /root/.gnupg &>/dev/null
    chmod -R 600 /root/.gnupg &>/dev/null
	key_name=${1}
	key_src=${2}
    # Check if key exists
    task INFO "Checking apt source signing key link available..."
    if [[ $(wget -S --spider ${key_src} 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
        task PASS
    else
        task FAIL
        message FAIL "There is a problem with the key source. Check URL link."
        exit 1
    fi
	message INFO "Fetching package signing key..."
    message INFO "SRC: ${key_src}"
	# Must be run without run_command or supressing output.
    wget -qO- ${key_src} > /tmp/${key_name}
	# If key is ascii-armored use gpg --deamor.
	if [[ $(file "/tmp/${key_name}") == *"Public-Key (old)"* ]] &>/dev/null; then
        message INFO "Running gpg --dearmor and adding to keyrings..."
        message INFO "DEST: /usr/share/keyrings/${key_name}-keyring.gpg"
		cat /tmp/${key_name} | gpg --dearmor | tee /usr/share/keyrings/${key_name}-keyring.gpg &>/dev/null
	else
        message INFO "No dearmor required. Adding to keyrings..."
        message INFO "DEST: /usr/share/keyrings/${key_name}-keyring.gpg"
		cp /tmp/${key_name} /usr/share/keyrings/${key_name}-keyring.gpg &>/dev/null
	fi
	rm /tmp/${key_name} &>/dev/null
}

# Fetch repo signing key from keyserver
# Usage: fetch_keyserver_signing_key "customkeyname" "hkp://validkeyserver.com" "keyfingerprint"
fetch_keyserver_signing_key() {
	mkdir -p /root/.gnupg &>/dev/null
    chmod -R 600 /root/.gnupg &>/dev/null
	key_name=${1}
	key_server=${2}
	key_fingerprint=${3}
	message INFO "Fetching package signing key from keyserver..."
	gpg --no-default-keyring --keyring /usr/share/keyrings/${key_name}-keyring.gpg \
	--keyserver ${key_server} --recv-keys ${key_fingerprint}
}

message INFO "${TEMPLATE_NAME} TEMPLATE IMPORTED."