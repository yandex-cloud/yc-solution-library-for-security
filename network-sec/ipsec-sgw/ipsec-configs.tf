# ==================================================================
# IPsec configuration file builder for the selected remote SGW type.
# ==================================================================

# Create an SGW configuration file for the remote site
locals {

  subnets_pairs = flatten([
    for key in var.yc_subnets.prefix_list : [
      for val in var.remote_subnets : {
        yc     = key
        remote = val
      }
    ]
  ])

  remote_ipsec_config = templatefile("${path.module}/templates/ipsec-${var.remote_sgw.type}.tpl", {
    SGW_NAME      = var.yc_sgw.name
    YC_SGW_IP     = "${yandex_vpc_address.sgw_public_ip.external_ipv4_address[0].address}"
    REMOTE_SGW_IP = var.remote_sgw.outside_ip
    POLICY_NAME   = var.ipsec_policy.policy_name
    IKE_PROPOSAL  = var.ipsec_policy.ike_proposal
    ESP_PROPOSAL  = var.ipsec_policy.esp_proposal
    PSK           = var.ipsec_policy.psk
    # For remote SGW's which are supported the Routed mode (IPsec Tunnel interface)
    YC_SUBNETS = var.yc_subnets.prefix_list
    # For remote SGW's which are NOT SUPPORTED the Routed mode, e.g. Mikrotik
    SUBNETS_PAIRS = local.subnets_pairs
  })
}

resource "local_file" "remote_ipsec_config" {
  content  = local.remote_ipsec_config
  filename = "${var.remote_sgw.name}-config.txt"
}
