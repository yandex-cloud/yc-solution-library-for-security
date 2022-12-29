terraform {
  required_version = ">= 0.14"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.72.0"
    }
  }
}

provider "yandex" {
  folder_id = var.folder_id
  token     = "t1.9euelZrNkp7Mz5qcmZmZicyJzo-Uzu3rnpWaz4-JmozLisyZz5iMl82VypTl8_cCYUpi-e8nATsD_t3z90IPSGL57ycBOwP-.qWlXilfFMzG1JnI3prdNTEYEoRb9KwaITV_C4GGlfKpW-wL6Ad8BW142sRMiqGv6PawI6_NaTQ6voKZ3T1nWBg"
  #service_account_key_file = "./key.json"
}


