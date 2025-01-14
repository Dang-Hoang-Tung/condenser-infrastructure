/* Core modules of the data analysis cluster. */

# Reusable variables
locals {
  cluster_id = "${var.cluster_name}-${var.username}"
  # Cloud config name
  cloud_config_name = "${local.cluster_id}-cloud-config"
  # VM names
  host_vm_name   = "${local.cluster_id}-host"
  client_vm_name = "${local.cluster_id}-client"
  # Hostnames
  hostnames = {
    hdfs          = "hdfs-${local.cluster_id}"
    yarn          = "yarn-${local.cluster_id}"
    prometheus    = "prometheus-${local.cluster_id}"
    node_exporter = "nodeexporter-${local.cluster_id}"
    grafana       = "grafana-${local.cluster_id}"
    minio_s3      = "s3-${local.cluster_id}"
    minio_console = "cons-${local.cluster_id}"
  }
}

data "harvester_ssh_key" "mysshkey" {
  name      = var.keyname
  namespace = var.namespace
}

data "harvester_image" "img" {
  display_name = var.img_display_name
  namespace    = "harvester-public"
}

# Cloud config with secret
resource "harvester_cloudinit_secret" "cloud_config" {
  name      = local.cloud_config_name
  namespace = var.namespace

  user_data = templatefile("cloud_init.tmpl.yml", {
    public_key_openssh = data.harvester_ssh_key.mysshkey.public_key
  })
}

# Management VM
module "host_vm" {
  source = "./modules/virtual-machine"

  name        = local.host_vm_name
  description = "Cluster head node"
  namespace   = var.namespace

  cores = var.host_vm_cores
  ram   = var.host_vm_ram

  network_name           = var.network_name
  root_disk_size         = var.host_vm_hdd
  root_disk_image        = data.harvester_image.img.id
  cloud_init_secret_name = harvester_cloudinit_secret.cloud_config.name

  tags = {
    # Ingress configurations
    condenser_ingress_isEnabled = true
    condenser_ingress_isAllowed = true
    # condenser_ingress_hdfs_hostname       = local.hostnames.hdfs
    # condenser_ingress_hdfs_port           = 9870
    # condenser_ingress_yarn_hostname       = local.hostnames.yarn
    # condenser_ingress_yarn_port           = 8088
    condenser_ingress_prometheus_hostname = local.hostnames.prometheus
    condenser_ingress_prometheus_port     = 9090
    condenser_ingress_grafana_hostname    = local.hostnames.grafana
    condenser_ingress_grafana_port        = 3000
  }
}

# Client VM
module "client_vm" {
  source = "./modules/virtual-machine"

  name        = local.client_vm_name
  description = "Cluster client node"
  namespace   = var.namespace

  cores = var.client_vm_cores
  ram   = var.client_vm_ram

  network_name           = var.network_name
  root_disk_size         = var.client_vm_hdd
  root_disk_image        = data.harvester_image.img.id
  data_disk_size         = var.client_vm_hdd
  cloud_init_secret_name = harvester_cloudinit_secret.cloud_config.name

  tags = {
    # Ingress configurations
    condenser_ingress_isEnabled                  = true
    condenser_ingress_isAllowed                  = true
    condenser_ingress_os_hostname                = local.hostnames.minio_s3
    condenser_ingress_os_port                    = 9000
    condenser_ingress_os_protocol                = "https"
    condenser_ingress_os_nginx_proxy-body-size   = "100000m"
    condenser_ingress_cons_hostname              = local.hostnames.minio_console
    condenser_ingress_cons_port                  = 9001
    condenser_ingress_cons_protocol              = "https"
    condenser_ingress_cons_nginx_proxy-body-size = "100000m"
    condenser_ingress_nodeexporter_hostname      = local.hostnames.node_exporter
    condenser_ingress_nodeexporter_port          = 9100
    # condenser_ingress_yarn_hostname         = "${local.hostnames.yarn}-${count.index + 1}"
    # condenser_ingress_yarn_port             = 8042
  }
}
