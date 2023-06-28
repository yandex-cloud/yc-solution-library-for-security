output "domain" {
  value        = "example.com"                # Domain name 
}

output "folder_id" {
  value        = "b1gentmqf1ve9uc54nfh"         # Folder id where resources will be deployed
}

output "vpc_id" {
  value = "enp48c1ndilt42veuw4x"                # VPC id where resources will be deployed
}    

output "trusted_ip_for_mgmt" {
  value = ["A.A.A.A/32", "B.B.B.0/24"]          # List of trusted public IP addresses for management of Firezone VM
  
}

output "firezone" {
  value = {
    subdomain       = "vpn"                     # Subdomain for Firezone web portal
    subnet          = "192.168.1.0/24"          # Subnet/Mask for Firezone VM
    vm_username     = "admin"                   # VM username
    admin_email     = "admin@example.com"       # Admin email (login) for Firezone Web UI    
    version         = "0.7.32"                  # Firezone version 
    wg_port         = "51820"                   # WireGuard UDP port to use
  }
}

output "postgres" {
  value = {
    db_ver          = "15"                      # PostgeSQL cluster version
    db_user         = "dbadmin"                 # PostgeSQL database user name
    db_kc_name      = "kc-db"                   # PostgeSQL Keycloak database name
    db_firezone_name = "firezone-db"            # PostgeSQL Firezone database name
  }
}

output "keycloak" {
  value = {
    subdomain       = "kc"                      # Subdomain for Keycloak
    subnet          = "192.168.2.0/24"          # Subnet/Mask for Keycloak VM
    port            = "8443"                    # Keycloak HTTPS port listener
    image_folder_id = "b1g4n62gio32v96mdvrb"    # Do not change! Folder ID of Keycloak image    
    image_name      = "keycloak"                # Do not change! ID of Keycloak image
    vm_username     = "admin"                   # VM username
    admin_user      = "admin"                   # Keycloak admin user name
    le_cert_name    = "kc"                      # Keycloak certificate name for Yandex Certificate Manager
    test_user = {                               # test user for SSO and VPN verification 
      name      = "user"
      email     = "user@example.com"
    }
  }
}
