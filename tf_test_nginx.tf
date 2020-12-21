provider "yandex" {
  token                    = "AgAAAAAgYiFGAATuwXrJjUp3wEl6sEIebJqkUHg"
  cloud_id                 = "b1g42tecrt0ufgvepjpc"
  folder_id                = "b1g7e95k609jvijns2jm"
  zone                     = "ru-central1-c"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81d2d9ifd50gmvc03g"
    }
    size = 10
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/ubuntu/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt install -y nginx"    
    ]
  }
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}