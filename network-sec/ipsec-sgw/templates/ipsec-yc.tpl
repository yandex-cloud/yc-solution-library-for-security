# =============================================================
# StrongSwan configuration file for ${SGW_NAME} @ Yandex Cloud
# /etc/swanctl/swanctl.conf
# 
# StrongSwan configuration docs:
# https://docs.strongswan.org/docs/5.9/swanctl/swanctlConf.html
# =============================================================

connections {
  ${POLICY_NAME} {
    remote_addrs = ${REMOTE_SGW_IP}
    local {
      auth = psk
    }
    remote {
      auth = psk
    }
    version = 2 # IKEv2
    mobike = no
    proposals = ${IKE_PROPOSAL}, default
    dpd_delay = 10s
    children {
      ${POLICY_NAME} {
        # Local IPv4 subnets
        local_ts = 0.0.0.0/0

        # Remote IPv4 subnets
        remote_ts = 0.0.0.0/0

        start_action = start
        esp_proposals = ${ESP_PROPOSAL}
        dpd_action = clear

        if_id_in = 48
        if_id_out = 48
      }
    }
  }
}

# Pre-shared key (PSK) for IPSEC connection
secrets {
  ike-${POLICY_NAME} {
    secret = ${PSK}
  }
}