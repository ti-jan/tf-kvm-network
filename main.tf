variable "vm_template" {
  type        = map(string)
  description = "Template for the VM configuration"
}

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "tfnet" {
  name      = var.vm_template["network_name"]
  mode      = "nat"
  addresses = ["10.1.2.0/24"]
  autostart = true

  dhcp {
    enabled = false
  }
}

resource "libvirt_volume" "os_image" {
  name   = var.vm_template["os_image_name"]
  pool   = var.vm_template["storage_pool"]
  source = var.vm_template["os_image_url"]
  format = "qcow2"
}

resource "libvirt_volume" "os_volume" {
  name           = var.vm_template["os_volume_name"]
  base_volume_id = libvirt_volume.os_image.id
  pool           = var.vm_template["storage_pool"]
  size           = var.vm_template["disksize"] * 1024 * 1024 * 1024 // GB to Bytes conversion
}

data "template_file" "user_data" {
  template = file("${path.module}/${var.vm_template["cloud_init_file"]}")
}

data "template_file" "network_config" {
  template = file("${path.module}/${var.vm_template["network_config_file"]}")
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "cloudinit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = var.vm_template["storage_pool"]
}

resource "libvirt_domain" "domain" {
  name   = var.vm_template["name"]
  memory = var.vm_template["memory"]
  vcpu   = var.vm_template["cpu"]

  cpu {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    network_name   = var.vm_template["network_name"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.os_volume.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
