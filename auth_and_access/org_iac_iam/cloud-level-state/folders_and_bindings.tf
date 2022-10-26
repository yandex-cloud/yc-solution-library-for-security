
#Give sa-web-app-tf permission on cloud

data "yandex_resourcemanager_cloud" "web-app" {
  cloud_id = var.CLOUD_ID
}

data "yandex_iam_service_account" "sa-web-app-tf" {
  name = "sa-web-app-tf"
  folder_id = var.FOLDER_ID
}


resource "yandex_resourcemanager_cloud_iam_member" "compute-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "compute.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "vpc-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "vpc.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "dns-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "dns.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "mdb-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "mdb.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "storageadmin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "storage.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "viewer" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "viewer"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "serviceAccounts-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.web-app.id}"
  role     = "editor" # soon will be alter on "iam.editor"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-web-app-tf.id}"
}


#Create folders

resource "yandex_resourcemanager_folder" "prod-folder" {
  cloud_id = var.CLOUD_ID
  name = "prod-folder"
}

resource "yandex_resourcemanager_folder" "non-prod-folder" {
  cloud_id = var.CLOUD_ID
  name = "non-prod-folder"
}

resource "yandex_resourcemanager_folder" "dev-folder" {
  cloud_id = var.CLOUD_ID
  name = "dev-folder"
}

#Import groups to cloud tf
#network folder---------------
data "yandex_organizationmanager_group" network-viewer {
  name        = "cloud-web-app-project-group-network-viewer"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" gitlab-admin {
  name        = "cloud-web-app-project-group-gitlab-admin"
  organization_id = var.org_id
}

#prod folder---------------
data "yandex_organizationmanager_group" prod-devops {
  name        = "cloud-web-app-project-group-prod-devops"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" prod-sre {
  name        = "cloud-web-app-project-group-prod-sre"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" prod-sa-app {
  name        = "cloud-web-app-project-group-prod-sa-app"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" prod-dba {
  name        = "cloud-web-app-project-group-prod-dba"
  organization_id = var.org_id
}

#non-prod folder---------------
data "yandex_organizationmanager_group" non-prod-devops {
  name        = "cloud-web-app-project-group-non-prod-devops"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" non-prod-sre {
  name        = "cloud-web-app-project-group-non-prod-sre"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" non-prod-sa-app {
  name        = "cloud-web-app-project-group-non-prod-sa-app"
  organization_id = var.org_id
}

data "yandex_organizationmanager_group" non-prod-dba {
  name        = "cloud-web-app-project-group-non-prod-dba"
  organization_id = var.org_id
}

#dev folder---------------
data "yandex_organizationmanager_group" dev-network-ad {
  name        = "cloud-web-app-project-group-dev-network-ad"
  organization_id = var.org_id
}
data "yandex_organizationmanager_group" dev-devops {
  name        = "cloud-web-app-project-group-dev-devops"
  organization_id = var.org_id
}


# Create bindings for groups on folders 

#Network folder------------------------------------------------------------------
data "yandex_resourcemanager_folder" "network-folder" {
  name     = "network-folder"
}

resource "yandex_resourcemanager_folder_iam_member" "network-viewer1" {
  folder_id = data.yandex_resourcemanager_folder.network-folder.id
  role = "vpc.viewer"
  member = "group:${data.yandex_organizationmanager_group.network-viewer.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "network-viewer2" {
  folder_id = data.yandex_resourcemanager_folder.network-folder.id
  role = "monitoring.admin"
  member = "group:${data.yandex_organizationmanager_group.network-viewer.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "gitlab-admin" {
  folder_id = data.yandex_resourcemanager_folder.network-folder.id
  role = "gitlab.admin"
  member = "group:${data.yandex_organizationmanager_group.gitlab-admin.id}"
}

#Prod folder------------------------------------------------------------------
#prod-devops
resource "yandex_resourcemanager_folder_iam_member" "prod-devops1" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "k8s.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-devops2" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "container-registry.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-devops3" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "alb.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-devops4" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "k8s.cluster-api.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-devops5" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "vpc.user"
  member = "group:${data.yandex_organizationmanager_group.prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-devops6" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "load-balancer.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-devops.id}"
}

#prod-sre
resource "yandex_resourcemanager_folder_iam_member" "prod-sre1" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "compute.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-sre.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-sre2" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "loadtesting.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-sre.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-sre3" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "storage.configViewer"
  member = "group:${data.yandex_organizationmanager_group.prod-sre.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-sre4" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "alb.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-sre.id}"
}
#prod-dba
resource "yandex_resourcemanager_folder_iam_member" "prod-dba1" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "mdb.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-dba.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "prod-dba2" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "ydb.viewer"
  member = "group:${data.yandex_organizationmanager_group.prod-dba.id}"
}


#non-prod folder------------------------------------------------------------------
#non-prod-devops
resource "yandex_resourcemanager_folder_iam_member" "non-prod-devops1" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "k8s.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-devops2" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "container-registry.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-devops3" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "alb.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-devops4" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "k8s.cluster-api.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-devops5" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "vpc.user"
  member = "group:${data.yandex_organizationmanager_group.non-prod-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-devops6" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "load-balancer.admin"
  member = "group:${data.yandex_organizationmanager_group.non-prod-devops.id}"
}

#non-prod-sre
resource "yandex_resourcemanager_folder_iam_member" "non-prod-sre1" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "compute.operator"
  member = "group:${data.yandex_organizationmanager_group.non-prod-sre.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-sre2" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "loadtesting.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-sre.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-sre3" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id  
  role = "storage.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-sre.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-sre4" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "alb.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-sre.id}"
}

#non-prod-dba
resource "yandex_resourcemanager_folder_iam_member" "non-prod-dba1" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "mdb.admin"
  member = "group:${data.yandex_organizationmanager_group.non-prod-dba.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "non-prod-dba2" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "ydb.editor"
  member = "group:${data.yandex_organizationmanager_group.non-prod-dba.id}"
}


#dev folder------------------------------------------------------------------
#dev-network-ad
resource "yandex_resourcemanager_folder_iam_member" "dev-network-ad1" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "vpc.admin"
  member = "group:${data.yandex_organizationmanager_group.dev-network-ad.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "dev-network-ad2" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "monitoring.admin"
  member = "group:${data.yandex_organizationmanager_group.dev-network-ad.id}"
}

#dev-devops
resource "yandex_resourcemanager_folder_iam_member" "dev-devops1" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "k8s.admin"
  member = "group:${data.yandex_organizationmanager_group.dev-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "dev-devops2" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "container-registry.admin"
  member = "group:${data.yandex_organizationmanager_group.dev-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "dev-devops3" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "alb.admin"
  member = "group:${data.yandex_organizationmanager_group.dev-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "dev-devops4" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "k8s.cluster-api.cluster-admin"
  member = "group:${data.yandex_organizationmanager_group.dev-devops.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "dev-devops5" {
  folder_id = yandex_resourcemanager_folder.dev-folder.id
  role = "vpc.user"
  member = "group:${data.yandex_organizationmanager_group.dev-devops.id}"
}


#create sa-app and it binding (prod and non-prod)
#prod
resource "yandex_iam_service_account" "sa-app-prod" {
  name        = "sa-app-prod"
  folder_id = yandex_resourcemanager_folder.prod-folder.id
}
resource "yandex_resourcemanager_folder_iam_member" "sa-app-prod-bind1" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "lockbox.payloadViewer"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-prod.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "sa-app-prod-bind2" {
  folder_id = yandex_resourcemanager_folder.prod-folder.id
  role = "storage.uploader"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-prod.id}"
}

#non-prod
resource "yandex_iam_service_account" "sa-app-non-prod" {
  name        = "sa-app-non-prod"
  folder_id = yandex_resourcemanager_folder.prod-folder.id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-app-non-prod-bind1" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "lockbox.payloadViewer"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-non-prod.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "sa-app-non-prod-bind2" {
  folder_id = yandex_resourcemanager_folder.non-prod-folder.id
  role = "storage.uploader"
  member = "serviceAccount:${yandex_iam_service_account.sa-app-non-prod.id}"
}
