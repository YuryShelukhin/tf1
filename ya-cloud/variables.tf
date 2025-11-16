variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  sensitive   = true
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud folder ID"
  sensitive   = true 
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "/home/yury/HW/terraform/01/secrets/yandex-cloud-key.pub"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key"
  default     = "/home/yury/HW/terraform/01/secrets/yandex-cloud-key"  
}

# Внешний IP для Security Groups
variable "my_ip" {
  type        = string
  description = "Your external IP for SSH access"
  default     = "0.0.0.0/0"  # При необходимости заменю на мой IP
}