module "route_switcher_infra" {
  source    = "./modules/multi-vpc-infra/"
  folder_id = yandex_resourcemanager_folder.folder4.id
  # usually a management subnet. used for healthkeaking status of the appliance
  first_router_subnet   = yandex_vpc_subnet.subnet-a_vpc_4.id  # !!заменить здесь на mgmt 
  first_router_address  = "${cidrhost(var.subnet-a_vpc_4, 10)}"
  second_router_subnet  = yandex_vpc_subnet.subnet-b_vpc_4.id 
  second_router_address = "${cidrhost(var.subnet-b_vpc_4, 10)}"
}


module "network_a_protected" {
  source = "./modules/multi-vpc-protected-network/"
  #values below should be used the same in different protected networks
  sa_id                 = module.route_switcher_infra.sa_id
  load_balancer_id      = module.route_switcher_infra.load_balancer_id
  target_group_id       = module.route_switcher_infra.target_group_id
  bucket_id             = module.route_switcher_infra.bucket_id
  access_key            = module.route_switcher_infra.access_key
  secret_key            = module.route_switcher_infra.secret_key
  first_router_address  = module.route_switcher_infra.first_router_address
  second_router_address = module.route_switcher_infra.second_router_address
  #values below will change in different folders if network are located in different folders
  folder_id = yandex_resourcemanager_folder.folder1.id
  #values below will change in different networks
  vpc_id = yandex_vpc_network.vpc_name_1.id
  # first_az_rt is usually an active rt in first az , but back become backup if second_az appliace fails
  first_az_rt          = yandex_vpc_route_table.servers.id
  first_az_subnet_list = [yandex_vpc_subnet.subnet-a_vpc_1.id]
  # second_az_rt is usually an active rt in second az , but back become backup if first_az appliace fails
  second_az_rt          = yandex_vpc_route_table.servers-backup.id
  second_az_subnet_list = [yandex_vpc_subnet.subnet-b_vpc_1.id]

}


module "network_b_protected" {
  #values below will change in different networks
  source = "./modules//multi-vpc-protected-network/"
  #values below should be used the same in different protected networks
  sa_id                 = module.route_switcher_infra.sa_id
  load_balancer_id      = module.route_switcher_infra.load_balancer_id
  target_group_id       = module.route_switcher_infra.target_group_id
  bucket_id             = module.route_switcher_infra.bucket_id
  access_key            = module.route_switcher_infra.access_key
  secret_key            = module.route_switcher_infra.secret_key
  first_router_address  = module.route_switcher_infra.first_router_address
  second_router_address = module.route_switcher_infra.second_router_address
  #values below will change in different folders if network are located in different folders
  folder_id = yandex_resourcemanager_folder.folder2.id
  #values below will change in different networks
  vpc_id = yandex_vpc_network.vpc_name_2.id
  # first_az_rt is usually an active rt in first az , but back become backup if second_az appliace fails
  first_az_rt          = yandex_vpc_route_table.database.id
  first_az_subnet_list = [yandex_vpc_subnet.subnet-a_vpc_2.id]
  # second_az_rt is usually an active rt in second az , but back become backup if first_az appliace fails
  second_az_rt          = yandex_vpc_route_table.database-backup.id
  second_az_subnet_list = [yandex_vpc_subnet.subnet-b_vpc_2.id]

}
