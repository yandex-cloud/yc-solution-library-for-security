resource "random_pet" "this" {}
locals {
  name = "wazuh-vpc"
  labels = {
    owner       = "terraform"
    environment = "demo"
  }
  instance_name = "wazuh-${random_pet.this.id}"
  wazuh_profile = chomp(templatefile("${path.cwd}/profile.tftpl",
    {
      bucket_name = module.s3.bucket_name,
      bucket_path = "wazuh",
      username = "ubuntu",
      public_key = file("~/.ssh/id_rsa.pub")
      aws_key_id = module.s3.aws_key_id
      aws_secret_access_key = module.s3.aws_secret_access_key

    }
  ))
}
module "vpc" {
  source = "../modules/vpc"
  vpc_name =  local.name
  labels = local.labels
  vpc_subnets = {
    private-ru-central1-a  = {
      zone = "ru-central1-a",
      cidr = "10.216.0.0/20"
    }
  }
}
module "s3" {
  source = "../modules/s3"
  folder_id = var.folder_id
  name = "wazuh"
  roles = ["storage.admin","admin","audit-trails.viewer"]
  cloud_id = var.cloud_id
}
module "vm" {
  source = "../modules/vm"
  image_id = var.image_id
  instance_name = local.instance_name
  subnet_id = module.vpc.subnets_locations[0].subnet_id
  service_account_id = module.s3.iam_profile_id
  instance_type = "standard-v3"
  vm_metadata = {
    user-data = local.wazuh_profile
  }
  labels = local.labels
  use_nat = true
  memory = "12"
  cores = "4"
  core_fraction="20"

}
