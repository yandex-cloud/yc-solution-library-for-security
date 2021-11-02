//Create folders
resource "yandex_resourcemanager_folder" "folder1" {
  cloud_id = var.cloud_id
  name = var.vpc_name_1
}

resource "yandex_resourcemanager_folder" "folder2" {
  cloud_id = var.cloud_id
  name = var.vpc_name_2
}

resource "yandex_resourcemanager_folder" "folder3" {
  cloud_id = var.cloud_id
  name = var.vpc_name_3
}

resource "yandex_resourcemanager_folder" "folder4" {
  cloud_id = var.cloud_id
  name = var.vpc_name_4
}

resource "yandex_resourcemanager_folder" "folder5" {
  cloud_id = var.cloud_id
  name = var.vpc_name_5
}

resource "yandex_resourcemanager_folder" "folder6" {
  cloud_id = var.cloud_id
  name = var.vpc_name_6
}

resource "yandex_resourcemanager_folder" "folder7" {
  cloud_id = var.cloud_id
  name = var.vpc_name_7
}

resource "yandex_resourcemanager_folder" "folder8" {
  cloud_id = var.cloud_id
  name = var.vpc_name_8
}