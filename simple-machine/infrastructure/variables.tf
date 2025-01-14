# System variables

variable "cluster_name" {
  type    = string
  default = "simple"
}

variable "username" {
  type    = string
  default = "ucabhtd"
}

variable "namespace" {
  type    = string
  default = "ucabhtd-comp0235-ns"
}

variable "network_name" {
  type    = string
  default = "ucabhtd-comp0235-ns/ds4eng"
}

variable "keyname" {
  type    = string
  default = "ucabhtd-cnc"
}

variable "img_display_name" {
  type    = string
  default = "almalinux-9.4-20240805"
}

# Machine specs

variable "host_vm_cores" {
  type    = number
  default = 4
}

variable "host_vm_ram" {
  type    = string
  default = "8Gi"
}

variable "host_vm_hdd" {
  type    = string
  default = "20Gi"
}

variable "client_vm_cores" {
  type    = number
  default = 8
}

variable "client_vm_ram" {
  type    = string
  default = "32Gi"
}

variable "client_vm_hdd" {
  type    = string
  default = "50Gi"
}
