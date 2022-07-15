## Bash Scripts
### Installation and Configuration Scripts for Debian based systems and macOS
* Installers will use latest sources where possible from original publisher sites or github release repos.  
* NOTE: Most of the Debian app installers fetch 64-bit (amd64) sources, the scripts may need modification to run on other systems such as 32-bit systems.
* File hashes will be shown during installation for any downloaded packages for security comparison with publisher if required.
* *NOTE: Scripts inherit common functions from the imported <a href="https://github.com/bradsec/bashscripts/tree/main/templates" target="_blank">templates</a>.*


### Usage
* Clone the repo `git clone https://github.com/bradsec/bashscripts.git` and run the required .sh script.
* Alternatively copy/use the one-liner `sudo bash -c ...` terminal command shown below each script.

<br/><br/>

### 1. Debian/Ubuntu | Password Manager (Bitwarden / KeyPassXC) Installer for Linux
* Script will download latest BitWarden or KeyPassXC AppImage and create a desktop icon.  
* Installs to `/opt/{appname}`
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/passwordapps.sh" target="_blank">passwordapps.sh</a>
```terminal
1. Install Bitwarden (Uses an online vault)
2. Install KeePassXC (Uses an offline vault)
```
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/passwordapps.sh)"
```

### 2. Debian/Ubuntu | Note-Taking Apps (Joplin / Standard Notes) Installer for Linux
* Script will download latest Joplin or Standard Notes AppImage and create a desktop icon.  
* Installs to `/opt/{appname}`
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/noteapps.sh" target="_blank">noteapps.sh</a>
```terminal
1. Install Joplin
2. Install Standard Notes
```
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/noteapps.sh)"
```

### 3. Debian/Ubuntu | Secure Messenger Apps (Signal / Threema) Installer for Linux
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/messengerapps.sh" target="_blank">messengerapps.sh</a>
```terminal
1. Install Signal
2. Install Threema
```
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/messengerapps.sh)"
```

### 4. Debian/Ubuntu | Browser (Firefox / Brave / TOR) Installer for Linux
* Firefox install will remove any pre-existing Firefox package installations including Firefox ESR and replaced with latest version.  
* Firefox and TOR Browser install into `/opt/`
* Brave installs using publisher signing key and added apt source.
* Brave can then be removed and installed using `sudo apt install brave-browser` and `sudo apt remove brave-browser`  
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/browserapps.sh" target="_blank">browserapps.sh</a>
```terminal
1. Install Firefox
2. Install Google Chrome
3. Install Brave
4. Install TOR Browser
```
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/browserapps.sh)"
```

### 5. Debian/Ubuntu | Code Editors
* Script will provide a menu list of Code editors (Sublime-Text, VSCode or Codium) to install.
* Menu can also be used to later uninstall the application.  
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/codeeditapps.sh" target="_blank">codeeditapps.sh</a>
```terminal
1. Install Sublime-Text 3
2. Install Sublime-Text 4
3. Install VS Codium
4. Install VS Code
```
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/codeeditapps.sh)"
```

### 6. Debian/Ubuntu | VM Ware Workstation/Player and Oracle Virtual Box
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
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/vmapps.sh)"
```

### 7. Debian/Raspberry Pi | Unifi Controller
* Script will install configure unifi controller on core Debian or Raspberry Pi OS
* Tested on Pi 3B and 4 running Raspberry Pi OS Lite (April 2022 release) Debian 11 (bullseye)
* **IMPORTANT: BACKUP ANY EXISTING UNIFI CONTROLLER CONFIGURATION FIRST**
  * Settings > System > [Backup] > Download Backup
* *Not currently working on Ubuntu*
* View script: <a href="https://github.com/bradsec/bashscripts/tree/main/unifiapps.sh" target="_blank">unifiapps.sh</a>
```terminal
1. Setup Unifi Controller
2. Remove Unifi Controller
```
```terminal
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bradsec/bashscripts/main/unifiapps.sh)"
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
