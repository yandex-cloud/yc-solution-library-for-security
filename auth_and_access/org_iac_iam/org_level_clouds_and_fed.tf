/*
set up yc cli before
*/


#Create clouds
resource "yandex_resourcemanager_cloud" "create-clouds" {
  count = length(var.CLOUD-LIST)
  
  organization_id = var.ORG_ID
  name = var.CLOUD-LIST[count.index].name
  description = var.CLOUD-LIST[count.index].descr

  # Bind created cloud to the BA
  # https://cloud.yandex.ru/docs/billing/api-ref/BillingAccount/bindBillableObject
  provisioner "local-exec" {
    command = <<-CMD
    curl -s -d '{ "billableObject": { "id": "${self.id}", "type": "cloud" }}' -H "Authorization: Bearer $(yc iam create-token)" -X POST https://billing.api.cloud.yandex.net/billing/v1/billingAccounts/${var.BA_ID}/billableObjectBindings 
    CMD
  }
}

#---------------------------------------------


#Install Keycloak
module "keycloak" {
  count = var.KEYCLOAK == false ? 0 : 1
  source = "./module_keycloak"
  cloud_id = var.ORG_ADMIN_CLOUD_ID
  org_id = var.ORG_ID
  folder_id = var.ORG_ADMIN_FOLDER_ID
  dns_zone_name = var.DNS_ZONE_NAME
  kc_fqdn = var.KC_FQDN
  depends_on = [local_file.kc-users-lst]
}

output "federation_link" {
  value               = module.keycloak[0].federation_link
} 

output "keycloak_links" {
  value               = module.keycloak[0].keycloak_links
} 

output "federation_id" {
  value               = module.keycloak[0].federation_id
} 

#Give sa-org-admin permission on cloud-org-admin

data "yandex_resourcemanager_cloud" "cloud-org-admin" {
  cloud_id = var.ORG_ADMIN_CLOUD_ID
}

data "yandex_iam_service_account" "sa-org-admin" {
  name = "sa-org-admin"
  folder_id = var.ORG_ADMIN_FOLDER_ID
}

resource "yandex_resourcemanager_cloud_iam_member" "compute-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.cloud-org-admin.id}"
  role     = "compute.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-org-admin.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "vpc-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.cloud-org-admin.id}"
  role     = "vpc.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-org-admin.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "dns-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.cloud-org-admin.id}"
  role     = "dns.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-org-admin.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "mdb-admin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.cloud-org-admin.id}"
  role     = "mdb.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-org-admin.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "storageadmin" {
  cloud_id = "${data.yandex_resourcemanager_cloud.cloud-org-admin.id}"
  role     = "storage.admin"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-org-admin.id}"
}
resource "yandex_resourcemanager_cloud_iam_member" "viewer" {
  cloud_id = "${data.yandex_resourcemanager_cloud.cloud-org-admin.id}"
  role     = "viewer"
  member   = "serviceAccount:${data.yandex_iam_service_account.sa-org-admin.id}"
}
