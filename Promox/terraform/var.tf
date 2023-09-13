variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDT1pI8aefHE5OtYZkSxqxHzF58xoDhMjKstRkUwS2EwhfZHPsqKlUQ0s64YEYjQZlWg3AuGvO7//p/OdkZuoojBEnbOcMp6XN0yEgf/y1ii7dAODFERDSwF5xpdWI69DKyIo9SRYRLbNys+jC0jBbwICjUpR0qp6dQiyfyO4u8n8P1EAGOdmBRUPVSgsc4hn03FKKBawwqHDJTE1VpVkD/cqmt7vQ/ECmvjnf74lcJA2uQMHPdHZTuZ2WEntVLUu40m6Tiamp9cO8Bg/1I1BPXqZ7oJGl+jTZL59hEVOjM1wiP9XA9fC5Bvegi6TpqZ+uyM/fTMYrggAAUgZhgAWQ154eXwJkdF0acmddmEr3En5mFa8ZHUA0UFHcTpcogNgxQCOugdAyYcQXOLwKYn7g4ElQ8dyc2pe2PWk1XXBcwUWPk6v+pJIRlE+Hh5S9+t3yXjUPwYOhta8dh/YemIoBimDP09kc6jqpPf/tGJqCbhgd1MBYVc+prenoPBtfjM8k= tamld@Macbooks-MacBook-Pro.local"
}
variable "proxmox_host" {
    default = "pve"
}
variable "template_name" {
    default = "ubuntu-2004-cloudinit-template"
}
variable "token_id" {
    default = "root@pam!token"
}
variable "token_secret" {
    default = "2382082b-7271-4fe4-bb5d-010906285893"
}
variable "api_url" {
    default = "https://10.241.217.6:8006/api2/json"
}
