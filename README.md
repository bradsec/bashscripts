## Bash Scripts
### Installation and Configuration Scripts for Debian based systems and macOS
* Installers will use latest sources where possible from original publisher.
* File hashes will be shown during installation for any downloaded packages for security comparison with publisher if required.
* *Note: Scripts inherit common functions from the imported <a href="https://github.com/bradsec/bashscripts/tree/main/templates" target="_blank">templates</a>.*
<br/><br/>

### 1. Debian/Ubuntu | Password Manager (Bitwarden / KeyPassXC) Installer for Linux
* Script will download latest BitWarden or KeyPassXC AppImage and create a desktop icon.  
* Installs to `/opt/{passwordmanagername}`
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/passman.sh" target="_blank">passman.sh</a>
```terminal
1. Install Bitwarden (Uses an online vault)
2. Install KeePassXC (Uses an offline vault)
```
* *Clone repo or use one-liner command below:*
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/passman.sh)"
```

### 2. Debian/Ubuntu | Browser (Firefox / Brave / Tor) Installer for Linux
* Firefox install will remove any pre-existing Firefox package installations including Firefox ESR and replaced with latest version.  
* Firefox and Tor Browser install into `/opt/`
* Brave installs using publisher signing key and added apt source.
* Brave can then be removed and installed using `sudo apt install brave-browser` and `sudo apt remove brave-browser`  
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/browsers.sh" target="_blank">browsers.sh</a>
```terminal
1. Install Firefox
2. Install Brave
3. Install Tor Browser
```
* *Clone repo or use one-liner command below:*
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/browsers.sh)"
```

### 3. Debian/Ubuntu | Code Editors
* Script will provide a menu list of Code editors (Sublime-Text, VSCode or Codium) to install.
* Menu can also be used to later uninstall the application.  
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/codeedit.sh" target="_blank">codeedit.sh</a>
```terminal
1. Install Sublime-Text 3
2. Install Sublime-Text 4
3. Install VS Codium
4. Install VS Code
```
* *Clone repo or use one-liner command below:*
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/codeedit.sh)"
```

### 4. Debian/Ubuntu | VM Ware Workstation/Player and Oracle Virtual Box
* Script will allow installation of either VMWare Workstation or Player on Debian OS systems.
* Script will install the latest host modules from https://github.com/mkubecek/vmware-host-modules which allows it to install correctly on latest kernels. Working with Ubuntu 22.04.
* Note the download linux installation bundle for VMWare products is about **500MB**.  
* The original download bundle will be left in the `/tmp` directory. It can be removed or saved to alternate location if required.
* Menu can also be used to later uninstall the application. 
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/vmapps.sh" target="_blank">vmware.sh</a>
```terminal
1. Install VMWare Workstation
2. Install VMWare Player
3. Install Oracle Virtual Box
```
* *Clone repo or use one-liner command below:*
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/vmapps.sh)"
```

### 5. Debian/Raspberry Pi | Unifi Controller
* Script will install configure unifi controller on core Debian or Raspberry Pi OS
* Tested on Pi 3B and 4 running Raspberry Pi OS Lite (April 2022 release) Debian 11 
* **IMPORTANT: BACKUP ANY EXISTING UNIFI CONTROLLER CONFIGURATION FIRST**
* Settings > System > [Backup] > Download Backup
(bullseye)
* *Not currently working on Ubuntu*
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/unifi.sh" target="_blank">unifi.sh</a>
```terminal
1. Setup Unifi Controller
2. Remove Unifi Controller
```
* *Clone repo or use one-liner command below:*
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/unifi.sh)"
```

* Reboot after installation or removal.  
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