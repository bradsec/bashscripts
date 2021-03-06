# Debian Linux (including Kali, Ubuntu, PopOS)<br>Application Installation Automation Shell / Bash Scripts
These scripts have been created to simplify and automate the installation of various Debian Linux and some macOS applications. The scripts will work with most Debian based Linux distros such as Ubuntu, Kali and Pop!_OS.

### Notes
* Scripts inherit common functions from the imported <a href="https://github.com/bradsec/bashscripts/tree/main/templates" target="_blank">templates</a>.  
* Most of the Debian app installers fetch x64 sources, the script sources may need modification to run on other system architecture such as x86 (32-bit) or arm processors.
* Where possible installers will use latest sources from original author/publisher sites or github release repos instead of using Flatpaks or Snap Store package installs.  
* File hashes will be shown during installation for any downloaded packages for security comparison with publisher if required.
* Menu options for application installation and removal are provided in each script as per example below:

```terminal
==============
 Menu Options 
==============

1. Install Firefox
2. Install Google Chrome
3. Install Brave
4. Install TOR Browser

5. Remove Firefox
6. Remove Google Chrome
7. Remove Brave
8. Remove TOR Browser

9. Exit

   Enter option [1-9]: 
```


### Usage Options
1. Clone the repo and run the required script.
```terminal
git clone https://github.com/bradsec/bashscripts.git
sudo bash ./bashscripts/passwordapps.sh
```
2. Alternatively use the one line command provided and run the script directly. 
```
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/scriptname.sh)"
```

Scriptname | Compatability | Applications
---|---|---
<a href="https://github.com/bradsec/bashscripts/tree/main/passwordapps.sh" target="_blank">passwordapps.sh</a> | Debian/Ubuntu | **Bitwarden, KeePassXC**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/passwordapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/noteapps.sh" target="_blank">noteapps.sh</a> | Debian/Ubuntu | **Joplin, Standard Notes**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/noteapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/messengerapps.sh" target="_blank">messengerapps.sh</a> | Debian/Ubuntu | **Signal, Threema**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/messengerapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/officeapps.sh" target="_blank">officeapps.sh</a> | Debian/Ubuntu | **OnlyOffice, LibreOffice**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/officeapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/collabapps.sh" target="_blank">collabapps.sh</a> | Debian/Ubuntu | **Discord, Slack, Zoom, Microsoft Teams**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/collabapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/browserapps.sh" target="_blank">browserapps.sh</a> | Debian/Ubuntu | **Firefox, Google Chrome, Brave, TOR Browser**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/browserapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/codeeditapps.sh" target="_blank">codeeditapps.sh</a> | Debian/Ubuntu | **Sublime-Text 3 & 4, Visual Studio Codium, Microsoft Visual Studio Code (VSCode)**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/codeeditapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/vmapps.sh" target="_blank">vmapps.sh</a> | Debian/Ubuntu | **VMWare Workstation & Player, Oracle VirtualBox**
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/vmapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/goapps.sh" target="_blank">goapps.sh</a> | Debian/Ubuntu | **Go (golang) Programming Language** (**)
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/goapps.sh)"```
<a href="https://github.com/bradsec/bashscripts/tree/main/unifiapps.sh" target="_blank">unifiapps.sh</a> | Raspberry Pi | **Unifi Controller** (**)
|||```sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/unifiapps.sh)"```


### Notes/Troubleshooting 

#### ** Go (golang) install
If the Go path is not found for a non-root user try running the following command:  
`source /etc/profile.d/go.sh`

#### ** Raspberry Pi Unifi Controller install
* Reboot Raspberry Pi after installation or removal.  
* Check status of unifi service using: `sudo systemctl status unifi`  
```terminal
Sample output of running service (check Active: active)
unifi.service - unifi
     Loaded: loaded (/lib/systemd/system/unifi.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-05-12 14:52:18 AEST; 2min 17s ago
    Process: 511 ExecStart=/usr/lib/unifi/bin/unifi.init start (code=exited, status=0/SUCCESS)
```
* Once the service is running you can access the Unifi controller via a browser - https://localhost:8443 or https://unifihostipaddress:8443
* This needs to be HTTPS not HTTP otherwise you will get bad request. The Unifi controller runs on port 8443 by default. If you don't specify this at the end of the address you will get unable to connect or not found. 
* You will receive a self-signed certificate (SSL) warning which you will need to accept and elect to continue. If you are running on your own domain there are options to use a LetsEncrypt or other certificate provider to use your own certificate to remove this warning. This is out of scope of this guide as it will require a fair bit setup and depends on your network configuration.  
