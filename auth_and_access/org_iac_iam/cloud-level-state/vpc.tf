# Создание VPC сети
resource "yandex_vpc_network" "vpc-web-app" {
  name                = "vpc-web-app"
  folder_id           = var.FOLDER_ID
}


# Создание подсетей в prod folder
resource "yandex_vpc_subnet" "prod-subnet" {
  folder_id           = data.yandex_resourcemanager_folder.prod-folder.id
  count               = 3
  name                = "prod-${element(var.network_names, count.index)}"
  zone                = element(var.zones, count.index)
  network_id          = yandex_vpc_network.vpc-web-app.id
  v4_cidr_blocks      = [element(var.app_cidrs3, count.index)]
}

# Создание подсетей в non-prod folder
resource "yandex_vpc_subnet" "non-prod-subnet" {
  folder_id           = data.yandex_resourcemanager_folder.nonprod-folder.id
  count               = 3
  name                = "non-prod-${element(var.network_names, count.index)}"
  zone                = element(var.zones, count.index)
  network_id          = yandex_vpc_network.vpc-web-app.id
  v4_cidr_blocks      = [element(var.app_cidrs2, count.index)]
}


