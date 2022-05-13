#!/usr/bin/env bash

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
        task PASS
        tput cnorm
        kill ${spinner_pid}
    else
        cmd_output=$(${cmd} 2>&1)
        task FAIL
        message INFO "${cmd_output}"
        tput cnorm
        kill ${spinner_pid}
    fi
    set -o errexit
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
        message INFO "Running gpg --dearmor on Public-Key and copying..."
        message INFO "DEST: /usr/share/keyrings/${key_name}-keyring.gpg"
		cat /tmp/${key_name} | gpg --dearmor | tee /usr/share/keyrings/${key_name}-keyring.gpg &>/dev/null
	else
        message INFO "No dearmor required copying Public-Key..."
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


main() {
    clear
    echo -e "Testing message and task information terminal output...\n"

    task INFO "This is a task that passed with no new text." && sleep 1
    task PASS    

    task INFO "This is a task that failed with no new text." && sleep 1
    task FAIL   

    task INFO "This is a task that passed and text will be replaced..." && sleep 1
    task PASSINFO "This is the replacement pass text." 

    task INFO "This is a task that failed and text will be replaced..." && sleep 1
    task FAILINFO "This is the replacement fail text." 

    message INFO "This is a INFO message" && sleep 1
    message INFOFULL "This is a INFOFULL message"

    message WARN "This is a WARN message" && sleep 1
    message WARNFULL "This is a WARNFULL message"

    message DONE "This is a DONE message" && sleep 1
    message DONEFULL "This is a DONEFULL message"

    message FAIL "This is a FAIL message" && sleep 1
    message FAILFULL "This is a FAILFULL message"

    echo -e "\nTesting run_command() function pass and fail...\n"

    message INFO "This command should pass..."
    run_command ls

    message INFO "This command should pass..."
    run_command df -h

    message INFO "This command should pass..."
    run_command mkdir -p /tmp/this123

    message INFO "This command should pass..."
    run_command rmdir /tmp/this123

    message INFO "This command should pass..."
    run_command touch /tmp/thisfile.txt

    message INFO "This command should pass..."
    run_command chmod 755 /tmp/thisfile.txt

    message INFO "This command should pass..."
    run_command rm /tmp/thisfile.txt

    message INFO "Running 8 second command."
    run_command sleep 8

    message INFO "This command should fail..."
    run_command badcmdabcdef1234
}

main