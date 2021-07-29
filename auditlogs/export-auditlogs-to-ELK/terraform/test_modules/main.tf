
//Пререквизиты: 
//-наличие сети
//-наличие подсетей в 3-х зонах
//-наличие SA
module "First-module" {
    source = "../modules/1_module_Creator/" #path to module #1 
    
    folder_id = var.folder_id
    cloud_id = var.cloud_id
    subnet_ids = ["e9boih92qspkol5morvl", "e2lbe671uvs0i8u3cr3s", "b0c0ddsip8vkulcqh7k4"]  #subnets в 3-х зонах доступности для развертывания ELK
    network_id = "enp5t00135hd1mut1to9" # network id в которой будет развернут ELK
}



module "Second-module" {
    source = "../modules/2_module_Sync/" #path to module #2
    
    folder_id = var.folder_id
    cloud_id = var.cloud_id
    elk_credentials = module.First-module.elk-pass
    elk_address = module.First-module.elk_fqdn
    bucket_name = "bucket-mirtov8"
    bucket_folder = "folder"
    sa_id = "aje5h5587p1bffca503j"
    coi_subnet_id = "e9boih92qspkol5morvl"
}

output "elk-pass" {
      value = module.First-module.elk-pass
      sensitive = true
    }
//Чтобы посмотреть пароль ELK: terraform output elk-pass

output "elk_fqdn" {
      value = module.First-module.elk_fqdn
    }