
# Things to do when install a fresh Proxmox VE 

## 1. Run proxmox scripts helper that can obtain useful settings
> https://tteck.github.io/Proxmox/

> [!NOTE]  
> Subscription Enterprise is enabled by default. Disable and use no-subscription for update/upgrade

 + `Proxmox VE Tools` should be run first
 + Scripts are recommended to run directly from the server web GUI shell instead of the terminal

## 2. Install Webmin System Administration for Web administrative purposes
`bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/webmin.sh)"`

## 3. Install ISC DHCPd Server (Webmin System Administration Module Installation) for Host only Setting
> [!NOTE]  
> Follow the config example below:

<!--
/etc/init.d/isc-dhcp-server stop
/etc/init.d/isc-dhcp-server start
/etc/init.d/isc-dhcp-server restart
/var/lib/dhcp/dhcpd.leases 
-->

| Settings | Description |
| --- | --- |
| `Subnet description` | Host only |
| `Network address` | 192.168.153.0 | 
|`Netmask` | 255.255.255.0 |
| `Address ranges` | 192.168.153.20-200 |
| `Listen on interfaces` | vmbr1 |

> /etc/init.d/isc-dhcp-server stop
/etc/init.d/isc-dhcp-server start
/etc/init.d/isc-dhcp-server restart
/var/lib/dhcp/dhcpd.leases
## 4. Add vmbr1 with the following settings below to grant IP for Scope Network Host Only
For further information, take a glance at:
https://pve.proxmox.com/wiki/Network_Configuration

`vi /etc/network/interfaces.new`
```ruby
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

## 5. Keywords self learning
| Keyword | Description | Example | 
| --- | --- | --- |
| `pve` | Node Proxmox Name | pve |
| `localnetwork` | VNet in Proxmox | vmbr0, vmbr1 |
|`local` | local storage | Backup, ISO Images, CT Templates |
|`local` | CT Templates | PATH /var/lib/vz/template/cache/ |
|`local` | ISO Images| PATH /var/lib/vz/template/iso/ |
| `local-lvm` | LVM storage | VM Disks, CT Volumes |
| `zfs` | storage pool | Snapshot, Clone, Checksum, Data intergrity, Fault tolerance, Expandable quotas ...etc |
| `zfs` | VM Disks | PATH /dev/zvol/zfs/ | 
| `zfs` | CT Volumes | PATH /zfs | 
| `CT` | Container (LXC) | Less resource | 
| `VM` | Virtual Machine (KVM) | More secure |
| `Listen on interfaces` | vmbr1 |







