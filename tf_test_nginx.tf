provider "yandex" {
  token                    = ""
  cloud_id                 = ""
  folder_id                = ""
  zone                     = "ru-central1-c"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81d2d9ifd50gmvc03g"
      size = 10
    }    
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/ubuntu/.ssh/id_rsa.pub")}"
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/tmp/index.html"

    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      host = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
      private_key = "${file("/home/ubuntu/.ssh/id_rsa")}"
    }
  } 

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      host = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
      private_key = "${file("/home/ubuntu/.ssh/id_rsa")}"
    }

    inline = [
      "sudo apt update && sudo apt install -y nginx", 
      "sudo rm -rf /var/www/html/*", 
      "sudo cp /tmp/index.html /var/www/html/index.html"
    ]
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
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
