variable "region01" {
  type = string
}

variable "region02" {
  type = string
} 

variable "owner_gke" {
  type = string
}

variable "activity" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "gke_num_nodes" {
  description = "number of gke nodes"
}

variable "cluster_name01" {
  type = string
}

variable "cluster_name02" {
  type = string
}


variable "machine_type" {
  type = string
}

variable "tokenexpirehours" {
  type = number
  default = 36
}

variable "project" {
  type = string
}

variable "az01" {
  type = list(string)
}

variable "az02" {
  type = list(string)
}

variable "subnet_cidr_block_ipv4" {
    type = string
}
