vm_template = {
  name                = "tf-vm-01"
  cpu                 = 2
  memory              = 2048
  disksize            = 32
  storage_pool        = "default"
  os_image_name       = "tf_vm_01_image.qcow2"
  os_volume_name      = "tf_vm_01_volume.qcow2"
  network_name        = "tfnet"
  cloud_init_file     = "cloud-init.yml"
  network_config_file = "network_config.yml"
  os_image_url        = "/home/gean/kvm/templates/debian-12-generic-amd64.qcow2"
}
