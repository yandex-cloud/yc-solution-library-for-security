terraform {
  required_version = ">= 0.14"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.72.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.5.0"
    }
  }
}

provider "yandex" {
  folder_id = var.folder_id
  token     = "t1.9euelZqRio2ejZLNmpuMlJSQnsuOlu3rnpWazY3JkcmZlp6ZlJmMncmJm8rl8_dKTzBt-e9FH3My_N3z9wp-LW3570UfczL8.rdi07u0iKuQ93VQkIeZ2nrKHGngaOr9yy514vbyAAm3S5lh_fbVp2tbO-H6wmvQDpjDuTmFpwWPhTaKiBHiuAg"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
