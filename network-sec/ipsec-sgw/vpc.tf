# =============
# VPC Resources
# =============

# Define SGW Network
data "yandex_vpc_network" "yc_net" {
  folder_id = data.yandex_resourcemanager_folder.sgw_folder.id
  name      = var.yc_subnets.net_name
}

# Create SGW Subnet
resource "yandex_vpc_subnet" "sgw_subnet" {
  folder_id      = data.yandex_resourcemanager_folder.sgw_folder.id
  name           = "${var.yc_sgw.name}-subnet"
  description    = "YC IPsec Security gateway subnet"
  v4_cidr_blocks = [var.yc_sgw.subnet]
  zone           = var.yc_sgw.zone
  network_id     = data.yandex_vpc_network.yc_net.id
  labels         = var.labels
}

# Reserve a static IP for the SGW instance
resource "yandex_vpc_address" "sgw_public_ip" {
  folder_id = data.yandex_resourcemanager_folder.sgw_folder.id
  name      = var.yc_sgw.name
  external_ipv4_address {
    zone_id = var.yc_sgw.zone
  }
  labels = var.labels
}

# Create Security Group for SGW
resource "yandex_vpc_security_group" "sgw_sg" {
  folder_id   = data.yandex_resourcemanager_folder.sgw_folder.id
  name        = "${lower(var.yc_sgw.name)}-sg"
  description = "IPsec SGW VM"
  network_id  = data.yandex_vpc_network.yc_net.id
  labels      = var.labels

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "http"
    protocol       = "TCP"
    port           = "8000"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ipsec"
    protocol       = "UDP"
    port           = "500"
    v4_cidr_blocks = ["${var.remote_sgw.outside_ip}/32"]
  }

  ingress {
    description    = "ipsec"
    protocol       = "UDP"
    port           = "4500"
    v4_cidr_blocks = ["${var.remote_sgw.outside_ip}/32"]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# Get All Subnets inside of specified Network/VPC
data "yandex_vpc_subnet" "yc_sub_all" {
  folder_id = var.folder_id
  for_each  = toset(data.yandex_vpc_network.yc_net.subnet_ids)
  subnet_id = each.value
}

locals {
  single_list = ["one-value"]

  # Filter Subnets by var.remote_subnets list
  sub_list = tolist(var.yc_subnets.prefix_list)
  subnet_list = flatten([
    for sub_id in data.yandex_vpc_network.yc_net.subnet_ids : {
      id     = sub_id
      prefix = data.yandex_vpc_subnet.yc_sub_all[sub_id].v4_cidr_blocks[0]
    } if contains(local.sub_list, data.yandex_vpc_subnet.yc_sub_all[sub_id].v4_cidr_blocks[0])
  ])

  # generate yc CLI strings for apply RT to subnets
  yc_rt_cmd = "ids=\"${join(" ", flatten([
    for sub in local.subnet_list : ["${sub.id}"]
  ]))}\"; for id in $ids ; do yc vpc subnet update $id --route-table-name=${lower(var.yc_sgw.name)}-rt ; done"

}

# Create Route table for route traffic to the remote subnets via SGW
resource "yandex_vpc_route_table" "sgw_rt" {
  folder_id  = data.yandex_resourcemanager_folder.sgw_folder.id
  name       = "${lower(var.yc_sgw.name)}-rt"
  network_id = data.yandex_vpc_network.yc_net.id

  dynamic "static_route" {
    for_each = var.remote_subnets == null ? [] : var.remote_subnets
    content {
      destination_prefix = static_route.value
      next_hop_address   = var.yc_sgw.inside_ip
    }
  }

  dynamic "static_route" {
    for_each = [for el in local.single_list : el
    if var.yc_subnets.rt_internet_access == true]
    content {
      destination_prefix = "0.0.0.0/0"
      gateway_id         = yandex_vpc_gateway.egress_gw[0].id
    }
  }

}

# If yc_subnets.rt_internet_access = true, Gateway should be created
resource "yandex_vpc_gateway" "egress_gw" {
  count     = var.yc_subnets.rt_internet_access ? 1 : 0
  folder_id = var.folder_id
  name      = "${data.yandex_vpc_network.yc_net.name}-egw"
  shared_egress_gateway {}
}

# If yc_subnets.force_subnets_update = true, perform subnets update with yc
resource "null_resource" "yc_subnets_update" {
  count = var.yc_subnets.force_subnets_update ? 1 : 0
  provisioner "local-exec" {
    command = local.yc_rt_cmd
  }
  depends_on = [
    yandex_vpc_route_table.sgw_rt
  ]
}
