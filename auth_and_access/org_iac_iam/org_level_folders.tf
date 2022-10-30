resource "time_sleep" "wait_60_seconds2" {
  create_duration = "60s"
}


#Create folders for first cloud
resource "yandex_resourcemanager_folder" "first-folders" {
  count = length(var.CLOUD-LIST[0].folders)
  cloud_id = yandex_resourcemanager_cloud.create-clouds[0].id
  name = var.CLOUD-LIST[0].folders[count.index]
  depends_on = [time_sleep.wait_60_seconds2]
}

#Create folders for second cloud
resource "yandex_resourcemanager_folder" "second-folders" {
  count = length(var.CLOUD-LIST[1].folders)
  cloud_id = yandex_resourcemanager_cloud.create-clouds[1].id
  name = var.CLOUD-LIST[1].folders[count.index]
  depends_on = [time_sleep.wait_60_seconds2]
}

#Create bindings for network folder
# Create bindings for groups on networks folder for first cloud

resource "yandex_resourcemanager_folder_iam_member" "network1" {
  count = length(var.NETWORK-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[0].id
  role = var.NETWORK-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.network-folder-groups-cloud1[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "network2" {
  count = length(var.NETWORK-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[0].id
  role = var.NETWORK-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.network-folder-groups-cloud1[1].id}"
}

# Create bindings for groups on networks folder for second cloud
resource "yandex_resourcemanager_folder_iam_member" "network1-1" {
  count = length(var.NETWORK-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[0].id
  role = var.NETWORK-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.network-folder-groups-cloud2[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "network2-2" {
  count = length(var.NETWORK-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[0].id
  role = var.NETWORK-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.network-folder-groups-cloud2[1].id}"
}

#---

#Create bindings for prod folder
# Create bindings for groups on networks folder for first cloud
resource "yandex_resourcemanager_folder_iam_member" "prod1" {
  count = length(var.PROD-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[1].id
  role = var.PROD-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud1[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prod2" {
  count = length(var.PROD-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[1].id
  role = var.PROD-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud1[1].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prod3" {
  count = length(var.PROD-CLOUD_GROUPS[2].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[1].id
  role = var.PROD-CLOUD_GROUPS[2].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud1[2].id}"
}
# Create bindings for groups on networks folder for second cloud
resource "yandex_resourcemanager_folder_iam_member" "prod1-1" {
  count = length(var.PROD-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[1].id
  role = var.PROD-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud2[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prod1-2" {
  count = length(var.PROD-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[1].id
  role = var.PROD-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud2[1].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prod1-3" {
  count = length(var.PROD-CLOUD_GROUPS[2].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[1].id
  role = var.PROD-CLOUD_GROUPS[2].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud2[2].id}"
}

#---

#Create bindings for non-prod folder
# Create bindings for groups on networks folder for first cloud
resource "yandex_resourcemanager_folder_iam_member" "nonprod1" {
  count = length(var.NONPROD-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[2].id
  role = var.NONPROD-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.nonprod-folder-groups-cloud1[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nonprod2" {
  count = length(var.PROD-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[2].id
  role = var.PROD-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.nonprod-folder-groups-cloud1[1].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nonprod3" {
  count = length(var.PROD-CLOUD_GROUPS[2].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[2].id
  role = var.PROD-CLOUD_GROUPS[2].roles[count.index]
  member = "group:${yandex_organizationmanager_group.nonprod-folder-groups-cloud1[2].id}"
}

# Create bindings for groups on networks folder for second cloud
resource "yandex_resourcemanager_folder_iam_member" "nonprod1-1" {
  count = length(var.NONPROD-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[2].id
  role = var.NONPROD-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud2[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nonprod1-2" {
  count = length(var.NONPROD-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[2].id
  role = var.NONPROD-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud2[1].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nonprod1-3" {
  count = length(var.NONPROD-CLOUD_GROUPS[2].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[2].id
  role = var.NONPROD-CLOUD_GROUPS[2].roles[count.index]
  member = "group:${yandex_organizationmanager_group.prod-folder-groups-cloud2[2].id}"
}

#---

#Create bindings for dev folder
# Create bindings for groups on networks folder for first cloud
resource "yandex_resourcemanager_folder_iam_member" "dev1" {
  count = length(var.DEV-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[3].id
  role = var.DEV-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.dev-folder-groups-cloud1[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "dev2" {
  count = length(var.DEV-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.first-folders[3].id
  role = var.DEV-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.dev-folder-groups-cloud1[1].id}"
}

# Create bindings for groups on networks folder for second cloud
resource "yandex_resourcemanager_folder_iam_member" "dev1-1" {
  count = length(var.DEV-CLOUD_GROUPS[0].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[3].id
  role = var.DEV-CLOUD_GROUPS[0].roles[count.index]
  member = "group:${yandex_organizationmanager_group.dev-folder-groups-cloud2[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "dev1-2" {
  count = length(var.DEV-CLOUD_GROUPS[1].roles)
  folder_id = yandex_resourcemanager_folder.second-folders[3].id
  role = var.DEV-CLOUD_GROUPS[1].roles[count.index]
  member = "group:${yandex_organizationmanager_group.dev-folder-groups-cloud2[1].id}"
}