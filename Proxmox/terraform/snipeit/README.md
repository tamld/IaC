# Install SnipeIT using Ansile module
## 1. Overview
+ Install Ansible
+ Deploy VM using Terraform on Proxmox
  + main.tf declare VM provider, settings
  + var.tf declare variables type is used in Terraform
  + terraform.tfvars declare values, sensitive information
+ Setup config VM with Ansible
 + Install docker, docker compose
 + Clone repository SnipeIT from GitHub
 + Change pre-define settings in docker-compose.yml, .env.docker files
 + Bring up containers

## 2. Folder stucture
```bash
├── README.md
├── ansible
│   ├── inventory.ini
│   └── playbook.yml
├── crash.log
├── main.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars
├── tfplan
└── var.tf
```
## 3. Deployment
### 3.1 Install Ansible
Follow this guide to [install Ansile](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### 3.2 Initialize VM
#### 3.2.1 Create main.tf
[Read more at](https://github.com/tamld/IaC/blob/main/Proxmox/terraform/snipeit/main.tf)

#### 3.2.2 Create var.tf
Read more at [here](https://github.com/tamld/IaC/blob/main/Proxmox/terraform/snipeit/var.tf)

#### 3.2.3 Create terraform.tfvars
```vi terraform.tfvars```
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
### 3.3 Bring the VM Up
```bash
terraform plan
terraform apply 
```
### Ansible deployment
#### Add inventory file
```vi inventory```
```ruby
[YOUR_VM_HOSTNAME]
YOUR_VM_IP ansible_user=YOUR_VM_USER
```
#### Add playbook file
Read more at [here](https://github.com/tamld/IaC/blob/main/Proxmox/terraform/snipeit/ansible/playbook.yml)

Deploy the config onto remote VM
```ansible-playbook -i inventory.ini playbook.yml ```
+ If no errors occur that we are ready to use SnipeIT
+ By executing the `docker compose logs` inside the VM to see the details