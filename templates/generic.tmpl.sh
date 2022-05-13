#!/usr/bin/env bash

# generic.sh
# Functions/commands compatible with most Linux or macOS terminals.
# Note: This template needs to be imported first.

TEMPLATE_NAME="GENERIC"

set -o errexit
set -o pipefail

# Set colors for use in task terminal output functions
message_colors() {
    if [[ -t 1 ]]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        CYAN=$(printf '\033[36m')
        YELLOW=$(printf '\033[33m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    else
        RED=""
        GREEN=""
        CYAN=""
        YELLOW=""
        BOLD=""
        RESET=""
    fi
}
# Init terminal message colors
message_colors

# Terminal message output formatting
# message() function displays information on seperate lines.
message() {
    local option=${1}
    local text=${2}
    case "${option}" in
        INFO) echo -e "[${CYAN}INFO${RESET}] ${text}";;
        INFOFULL) echo -e "[${CYAN}INFO${RESET}] ${CYAN}${text}${RESET}";;
        WARN) echo -e "[${YELLOW}WARN${RESET}] ${text}";;
        WARNFULL) echo -e "[${YELLOW}WARN${RESET}] ${YELLOW}${text}${RESET}";;
        USER) echo -e "[${GREEN}USER${RESET}] ${text}";;
        FAIL) echo -e "[${BOLD}${RED}FAIL${RESET}] ${text}";;
        FAILFULL) echo -e "[${BOLD}${RED}FAIL${RESET}] ${RED}${text}${RESET}";;
        DONE) echo -e "[${BOLD}${GREEN}DONE${RESET}] ${text}";;
        DONEFULL) echo -e "[${BOLD}${GREEN}DONE${RESET}] ${GREEN}${text}${RESET}";;
        PASS) echo -e "[${BOLD}${GREEN}PASS${RESET}] ${text}";;
        *) echo -e "${text}";;
    esac
}

# task() function displays information and then the result on same line.
task() {
    local option=${1}
    local text=${2}
    case "${option}" in
        INFO) echo -ne "[-] ${text}";;
        PASS) echo -e "\r[\033[0;32m\xE2\x9C\x94\033[0m]";;
        PASSINFO) echo -e "\r[\033[0;32m\xE2\x9C\x94\033[0m] ${text}$(tput el)";;
        FAIL) echo -e "\r[\033[0;31m\xe2\x9c\x98\033[0m]";;
        FAILINFO) echo -e "\r[\033[0;31m\xe2\x9c\x98\033[0m] ${text}$(tput el)";;
     esac
}

# Date/time formatting
# Example output: 04-May-2022 21:04:14
get_date_time() {
	message INFO "$(date +"%d-%b-%Y %H:%M:%S")"
}



# Function to return OS and hardware details
# Usage example 1: get_os summary
# Usage example 2: thisvar=$(get_os release)
get_os() {
	if [[ $(command -v lsb_release) ]] >/dev/null 2>&1; then
        local codename=$(lsb_release -c --short)
        local release=$(lsb_release -r --short)
        local dist=$(lsb_release -d --short)
        local distid=$(lsb_release -i --short)
        local arch=$(uname -m)
        local dpkg_arch=$(dpkg --print-architecture)
        local check_cpu=$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)
        local check_model=$(cat /proc/cpuinfo | grep Model | head -1 | cut -d':' -f2 | xargs)
        if [[ -z "${check_cpu}" ]]; then
            local hardware="${check_model}"
        else
            local hardware="${check_cpu}"
        fi

        case ${1} in
            
            codename)
                echo -ne ${codename}
            ;;
            release)
                echo -ne ${release}
            ;;
            dist)
                echo -ne ${distro}
            ;;
            distid)
                echo -ne ${distid}
            ;;
            arch)
                echo -ne ${arch}
            ;;
            dpkg_arch)
                echo -ne ${dpkg_arch}
            ;;
            hardware)
                echo -ne ${hardware}
            ;;
            summary)
                message INFO "OS Detected: ${dist} ${arch}"
                message INFO "Hardware Detected: ${hardware}"
            ;;
            *) message WARN "Invalid get_os() function usage."
            ;;
        esac
    elif [[ $(sysctl -n machdep.cpu.brand_string) ]] >/dev/null 2>&1; then
        local hardware=$(sysctl -n machdep.cpu.brand_string | xargs)
        local dist=$(sw_vers -productVersion | xargs)
            case ${1} in
                summary)
                message INFO "OS Detected: ${dist} ${arch}"
                message INFO "Hardware Detected: ${hardware}"
                ;;
                *) message WARN "Invalid get_os() function usage."
                ;;
            esac
    fi
}

# Display press any key or do you wish to continue y/N.
# Example usage: wait_for user_anykey OR wait_for user_continue
wait_for() {
    echo
    case "${1}" in
        user_anykey) read -n 1 -s -r -p "[${GREEN}USER${RESET}] Press any key to continue. "
        echo -e "\n"
        ;;
        user_continue) local response
        while true; do
            read -r -p "[${GREEN}USER${RESET}] Do you wish to continue (y/N)?${RESET} " response
            case "${response}" in
            [yY][eE][sS] | [yY])
                echo
                break
                ;;
            *)
                echo
                exit
                ;;
            esac
        done;;
        *) message FAIL "Invalid function usage.";;
    esac
}

# Check is script is being run as superuser
check_superuser() {
    if [[ $(id -u) -ne 0 ]] >/dev/null 2>&1; then
        message FAIL "Script must be run by superuser or using sudo command.\n"
        exit 1
    fi
}

# Spinner used to show command is running.
# Ref: https://www.shellscript.sh/tips/spinner/
spinner()
{
  tput civis
  spinner="/|\\-/|\\-"
  while :
  do
    for i in `seq 0 7`
    do
      echo -ne "\r"  
      echo -n "[${GREEN}${spinner:$i:1}${RESET}"
      echo -en "\010"
      sleep 0.5
    done
  done
}

# run_command() best for short running commands as output will be suppressed.
# If command fails an error message will be displayed.
run_command() {
    set +o errexit
    local cmd=${@}
    if [[ ${DEBUG} == true ]]; then
        task INFO "RunCMD: ${0} Line: ${LINENO} ${cmd:0:64}..."
    else
        task INFO "RunCMD: ${cmd:0:64}..."
    fi
    spinner &
    spinner_pid=$!
    trap "kill -9 ${spinner_pid}" `seq 0 15`
    trap "tput cnorm" EXIT
    ${cmd} > /dev/null 2>&1
    exit_code=${?}
    if [[ ${exit_code} -eq 0 ]]; then
        kill ${spinner_pid}
        task PASS
        tput cnorm
    else
        kill ${spinner_pid}
        cmd_output=$(${cmd} 2>&1)
        task FAIL
        message INFO "${cmd_output}"
        tput cnorm
    fi
    set -o errexit
}

# Write text config to a file
# Example usage: write_config "this text" "thisfile.txt"
write_config_file() {
    local filename=${2}
    local content=${1}
    message INFO "Writing config file ${filename}..."  
    cat > ${filename} << EOL
${content}
EOL
}

# Display file hash information
# Example usage 1: file_hash all "thisfile.ext"
# Example usage 2: thishash=$(file_hash sha256 "thisfile.ext")
file_hash(){
    local option=${1}
    local filename=${2}
    case "${option}" in
        all) message INFO "File hash values for ${filename}...\n"
            echo -e "   MD5 $(md5sum ${filename} | cut -d ' ' -f 1)"
            echo -e "  SHA1 $(sha1sum ${filename} | cut -d ' ' -f 1)"
            echo -e "SHA256 $(sha256sum ${filename} | cut -d ' ' -f 1)\n";;
        md5) echo -ne "$(md5sum ${filename} | cut -d ' ' -f 1)";;
        sha1) echo -ne "$(sha1sum ${filename} | cut -d ' ' -f 1)";;
        sha256) "SHA256 $(sha256sum ${filename} | cut -d ' ' -f 1)\n";;
        *) message FAIL "Invalid function usage.";;
    esac
}

# Compare two values
# Example usage: compare_hashes "hashvalue1" "hashvalue2"
compare_values(){
    if [ "${1}" == "${2}" ]; then
        message PASS "The two values match."
    else
        message FAIL "The two values did not match."
        exit 1
    fi
}


# Download file from URL
# Example usage: download_file "newfilename.ext" "https://urloffiletobedownloaded"
download_file() {
	local dst_file=${1}
	local src_url=${2}
	message INFO "Downloading file..."
    message INFO "SRC: ${src_url}"
    message INFO "DEST: ${dst_file}"
	if wget --user-agent=Mozilla --content-disposition -c -E -O \
	"${dst_file}" "${src_url}" -q --show-progress --progress=dot:giga; then
        echo
		message DONE "File successfully downloaded."
	else
		message WARN "There was a problem downloading the file. Trying another method..."
		message INFO "Trying wget without resume option..."
			if wget --user-agent=Mozilla --content-disposition -E -O \
				"${dst_file}" "${src_url}" -q --show-progress --progress=dot:giga; then
                    echo
					message DONE "File successfully downloaded."
			else
				message WARN "There was a problem downloading the file. Trying final method..."
				message INFO "Trying download using curl instead or wget command...\n"
				if curl -# -J -L "${src_url}" -o "${dst_file}"; then
                    echo
					message DONE "File successfully downloaded."
				else
					message FAIL "There was a problem downloading the file. Check url and source file."
				fi
			fi
	fi
    file_hash all ${dst_file}
}


# Download url plaintext or similar type content and output to screen
# Example usage: download_content "https://urlofplaintextcontent"
download_content() {
	local src_url=${1}
	message INFO "Downloading required plain text content..."
    message INFO "Source: ${src_url}"
	if output=$(wget -qO- ${src_url} 1> /dev/null); then
		echo "${output}"
	else
		message FAIL "Unable to fetch content."
	fi
}


message INFO "${TEMPLATE_NAME} TEMPLATE IMPORTED."