
# Things to do when install a fresh Proxmox VE

## 1. Run proxmox scripts helper that can obtain usefull settings:
`https://tteck.github.io/Proxmox/`
> [!NOTE]
> Notes:
 + *Proxmox VE Tools* should be run first
 + Scripts is recommended to run directly from server web gui shell instead of terminal
 
## 2. Install Webmin System Administration for a webgui administrative purposes
`bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/webmin.sh)"`

## 3. Install ISC DHCPd Server (Webmin System Administration Module Installation) for Host only Setting
> [!NOTE]
> Notes:
 + Subnet network should be config with 192.168.153.0/255.255.255.0
 + Range network with in the subnet values
 + Configure Interfaces that the ISC DHCPd services will listen on (vmbr1)

## 4. Add vmbr1 with the following settings bellow to grant IP for Host Only Scope Network
for further information, take a look at:
https://pve.proxmox.com/wiki/Network_Configuration

`vi /etc/network/interfaces.new`
```json
auto lo
iface lo inet loopback

iface enp3s0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.168.100.71/24
        gateway 192.168.100.99
        bridge-ports enp3s0
        bridge-stp off
        bridge-fd 0

iface wlp4s0 inet manual

auto vmbr1
iface vmbr1 inet static
        address 192.168.153.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
#Host Only
```