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
  token     = "t1.9euelZrOkM2UksuclovNjcmKzJiZx-3rnpWaz4-JmozLisyZz5iMl82VypTl8_ceB3Ri-e8vdH48_t3z9141cWL57y90fjz-.TcB3v5nA-AamJMZVZ5qFj0DwlNDNRAdr4Nai34vl_IBN94dRnluHGhzUALh0FJk02t4g2kTE1RgNf2OFx-YKBg"
  #service_account_key_file = "./key.json"
}


