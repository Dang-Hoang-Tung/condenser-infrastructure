# System variables

variable "cluster_name" {
  type    = string
  default = "adl"
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

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_cores" {
  type    = number
  default = 18
}

variable "vm_ram" {
  type    = string
  default = "64Gi"
}

variable "vm_hdd" {
  type    = string
  default = "150Gi"
}
