# Deploy VM and install unattended packages using Ansible
## 1. Overview
+ Install Ansible
+ Deploy VM using Terraform on Proxmox
  + main.tf declare VM provider, settings
  + var.tf declare variables type is used in Terraform
  + terraform.tfvars declare values, sensitive information
+ Setup config VM with Ansible
 + Update, upgrade
 + Install other packages by scripts
> [!NOTE] There are some missing files that you can not reach due to sensetive information. To suit your settings, follow my template file instead
## 2. Folder stucture
```bash
├── README.md
├── ansible
│   └── playbook.yml
├── main.tf
├── terraform.tfvars
├── tfplan
└── var.tf
```

## 3. Deployment
### 3.1 Install Ansible
Follow this guide to [install Ansile](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### 3.2 Initialize VM
#### 3.2.1 Create main.tf
Use this [template](https://github.com/tamld/IaC/blob/main/Promox/terraform/clone-vm-static-ip/main.tf)

#### 3.2.2 Create var.tf
Use this [template](https://github.com/tamld/IaC/blob/main/Promox/terraform/clone-vm-static-ip/var.tf)

#### 3.2.3 Create terraform.tfvars
```nano terraform.tfvars```
```ruby
# Proxmox settings
proxmox_host = "YOUR_PVE_HOST"
template_name = "YOUR_TEMPLATE_NAME"
token_id = "YOUR_TOKEN_NAME"
token_secret = "YOUR_TOKEN_SECRET"
pm_api_url = "https://YOUR_IP:8006/api2/json"
vm_number = "AMOUNT-VMS-NUMBER"
vm_cores = "AMOUNT-CPU-CORE"
vm_sockets = "AMOUNT-CPU-SOCKET"
vm_memory = "AMOUNT-RAM"
vm_name = "YOUR-VM-NAME"
username = "YOUR-USER-NAME"
password = "YOUR-PASSWORD"
ssh_keys= [
"YOUR 1ST PUBLIC KEY",
"YOUR 2ND PUBLIC KEY",
..
..
"YOUR N PUBLIC KEY"
]
```
#### 3.2.4 Create ansible playbook
Use this [template](https://github.com/tamld/IaC/blob/main/Promox/terraform/clone-vm-static-ip/ansible/playbook.yml)

### 3.3 Bring the VM Up
```bash
terraform plan
terraform apply 
```
### Ansible deployment
```
#### Add playbook file
Read more at [here](https://github.com/tamld/IaC/blob/main/Promox/terraform/snipeit/ansible/playbook.yml)
Ansible will run unattended and finish when all the tasks done!
Check the output for further information.
Deploy the config onto remote VM
+ If no errors occur that we are ready to use the VM
+ If we have declared Public key in the previous steps, just ssh by using SSH username@IP