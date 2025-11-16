# Генерация паролей
resource "random_password" "mysql_root_password" {
  length  = 16
  special = false
}

resource "random_password" "mysql_user_password" {
  length  = 16
  special = false
}

# Виртуальная машина
resource "yandex_compute_instance" "docker_vm" {
  name        = "docker-mysql-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.docker_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Сеть
resource "yandex_vpc_network" "docker_network" {
  name = "docker-network"
}

# Подсеть
resource "yandex_vpc_subnet" "docker_subnet" {
  name           = "docker-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.docker_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Установка Docker и запуск MySQL
resource "null_resource" "setup" {
  depends_on = [yandex_compute_instance.docker_vm]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = yandex_compute_instance.docker_vm.network_interface.0.nat_ip_address
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      # Установка Docker
      "sudo apt-get update && sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      
      # Запуск MySQL контейнера
      "sudo docker run -d --name mysql_${random_password.mysql_root_password.result} -p 127.0.0.1:3306:3306 -e MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result} -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=${random_password.mysql_user_password.result} -e MYSQL_ROOT_HOST=% mysql:8",
      
      # Проверка
      "sudo docker ps"
    ]
  }
}

# Output значения (без дубликатов)
output "vm_public_ip" {
  value = yandex_compute_instance.docker_vm.network_interface.0.nat_ip_address
}

output "mysql_root_password" {
  value     = random_password.mysql_root_password.result
  sensitive = true
}

output "mysql_user_password" {
  value     = random_password.mysql_user_password.result
  sensitive = true
}

output "ssh_connection_command" {
  value = "ssh -i ${var.ssh_private_key_path} ubuntu@${yandex_compute_instance.docker_vm.network_interface.0.nat_ip_address}"
}

output "mysql_connection_info" {
  value = "MySQL запущен на: 127.0.0.1:3306 (внутри ВМ)"
}

output "check_container_command" {
  value = "ssh -i ${var.ssh_private_key_path} ubuntu@${yandex_compute_instance.docker_vm.network_interface.0.nat_ip_address} 'docker ps'"
}