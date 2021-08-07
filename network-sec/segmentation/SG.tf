
resource "yandex_vpc_security_group" "sg-inet-acc" {
  name        = "sg-inet-acc"
  description = "defines which environments can access NAT-Instance for Internet access"
  network_id  = yandex_vpc_network.vpc-infra.id


  ingress {
    protocol       = "ICMP"
    description    = "Allow pings from all networks for tshoot"
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol       = "TCP"
    description    = "CI-CD can only access well-known ports to update packages"
    security_group_id  = yandex_vpc_security_group.sg-ci-cd.id
    port      = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "CI-CD can only access well-known ports to update packages"
    security_group_id  = yandex_vpc_security_group.sg-ci-cd.id
    port      = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "stage can only access well-known ports to update packages"
    security_group_id  = yandex_vpc_security_group.sg-stage.id
    port      = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "stage can only access well-known ports to update packages"
    security_group_id  = yandex_vpc_security_group.sg-stage.id
    port      = 80
  }


  egress {
    protocol       = "ANY"
    description    = "NAT-INSTANCE can access internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_security_group" "sg-bastion" {
  name        = "sg-bastion"
  description = "allows connecting to bastion only from whitelisted address"
  network_id  = yandex_vpc_network.vpc-infra.id

  labels = {
     type = "bastion-whitelist"
   }


  ingress {
    protocol       = "TCP"
    description    = "allow-ssh-from-trusted-ip"
    v4_cidr_blocks = var.bastion_whitelist_ip
    port           = 22
  }


  ingress {
    protocol       = "ICMP"
    description    = "allow-icmp-from-trusted-ip"
    v4_cidr_blocks = var.bastion_whitelist_ip
  }

  egress {
    protocol       = "ANY"
    description    = "we allow any egress, since we block on ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sg-ci-cd" {
  name        = "sg-ci-cd"
  description = "allows ci-cd tools to manage stage and prod"
  network_id  = yandex_vpc_network.vpc-infra.id


  ingress {
    protocol       = "TCP"
    description    = "allows remote access only through Bastion"
    security_group_id  = yandex_vpc_security_group.sg-bastion.id
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allows ping only from bastion"
    security_group_id  = yandex_vpc_security_group.sg-bastion.id
  }


  ingress {
  protocol          = "TCP"
  description       = "allows for config sync for ci-cd workers"
  predefined_target = "self_security_group"
  port = 22
}

  egress {
    protocol       = "ANY"
    description    = "we allow any ingress, since we block prod on ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sg-dev" {
  name        = "sg-dev"
  description = "allows isolated dev environment, can be accesed from whitelisted ip"
  network_id  = yandex_vpc_network.vpc-infra.id
  folder_id = var.dev_folder_id


  ingress {
    protocol       = "TCP"
    description    = "allow-ssh-from-trusted-ip"
    v4_cidr_blocks = var.bastion_whitelist_ip
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow-icmp-from-trusted-ip"
    v4_cidr_blocks = var.bastion_whitelist_ip
  }


  egress {
    protocol       = "ANY"
    description    = "we allow any egress for sandbox, since we block prod on ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

  resource "yandex_vpc_security_group" "sg-stage" {
    name        = "sg-stage"
    description = "allows ci-cd tools to manage stage and prod"
    network_id  = yandex_vpc_network.vpc-infra.id
    folder_id = var.stage_folder_id


    ingress {
      protocol       = "TCP"
      description    = "allows remote access through Bastion"
      security_group_id  = yandex_vpc_security_group.sg-bastion.id
      port           = 22
    }

    ingress {
      protocol       = "ICMP"
      description    = "allows ping  through Bastion"
      security_group_id  = yandex_vpc_security_group.sg-bastion.id
    }

    ingress {
      protocol       = "TCP"
      description    = "allows deploy from ci-cd"
      security_group_id  = yandex_vpc_security_group.sg-ci-cd.id
      port           = 22
    }

    ingress {
      protocol       = "ICMP"
      description    = "allows ping from ci cd"
      security_group_id  = yandex_vpc_security_group.sg-ci-cd.id
    }

    egress {
      protocol       = "ANY"
      description    = "we allow any egress for stage, since we block prod on ingress"
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "sg-prod" {
      name        = "sg-prod"
      description = "allows ci-cd tools to manage stage and prod"
      network_id  = yandex_vpc_network.vpc-infra.id
      folder_id = var.prod_folder_id

      ingress {
        protocol       = "TCP"
        description    = "allows deploy from ci-cd only no manual access"
        security_group_id  = yandex_vpc_security_group.sg-ci-cd.id
        port           = 22
      }

      ingress {
        protocol       = "icmp"
        description    = "allows ping from ci cd only"
        security_group_id  = yandex_vpc_security_group.sg-ci-cd.id
      }

      egress {
        protocol       = "ANY"
        description    = "we allow any egress for stage, since we block prod on ingress"
        v4_cidr_blocks = ["0.0.0.0/0"]
      }
  }
