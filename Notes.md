
# A. Fresh Proxmox VE Installation
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

# B. Self learning
## 1. Keyword, explaination and example 
| Keyword | Description | Example | 
| --- | --- | --- |
| `pve` | Node Proxmox Name | pve |
| `localnetwork` | VNet in Proxmox | vmbr0, vmbr1 |
|`local-local storage` | local storage | Backup, ISO Images, CT Templates |
| | CT Templates | PATH /var/lib/vz/template/cache/ |
| | ISO Images| PATH /var/lib/vz/template/iso/ |
| `local-lvm` | LVM storage | VM Disks, CT Volumes |
| `zfs` | storage pool | Snapshot, Clone, Checksum...etc |
|  | VM Disks | PATH /dev/zvol/zfs/ | 
|  | CT Volumes | PATH /zfs | 
| `CT` | Container (LXC) | Less resource | 
| `Realms` | Authenticate Methods | PAM, PVE, LDAP, OpenID |
| `Permisions` | Datacenter settings | modify user settings |
| | Users | Add, modify user permisions |
|  | API Tokens | Add, edit, delete API settings |
|  | Privilege Seperation | Decide that API and user's roles are not the same settings  |
|  | API Tokens | Add, edit, delete API settings |

## 2. Proceduce steps
### 2.1 Create users
```json
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
\#Add user 'terraform-pro' with password 'P@ssw0rd'
pveum user add terraform-prov@pve --password P@ssw0rd
pveum aclmod / -user terraform-prov@pve -role TerraformProv```

## 3. Reference Links
+ `Infrastructure as Code with Terraform`: [Hashicorp](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code).
+ `Terraform provider plugin for Proxmox`: [Telmate Github Repo](https://github.com/Telmate/terraform-provider-proxmox#terraform-provider-plugin-for-proxmox).
+ `ChristianLempa`: [boilerplates](https://github.com/ChristianLempa/boilerplates/tree/main/terraform/proxmox).
+ `How to deploy VMs in Proxmox with Terraform`: [Website] (https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/).
+ `Proxmox virtual machine *automation* in Terraform`: [Youtube](https://www.youtube.com/watch?v=dvyeoDBUtsU&ab_channel=ChristianLempa).
+ `Terraform Infrastructure as Code for Proxmox`: [Youtube](https://www.youtube.com/watch?v=DjmzVHj3AK0&ab_channel=EngineeringwithMorris).






