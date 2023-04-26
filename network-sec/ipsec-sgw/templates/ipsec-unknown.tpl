# =====================================
# IPSEC attributes for Remote IPSEC SGW
# =====================================

${POLICY_NAME}:
  mode: IPSEC Tunnel mode
  ike-version: IKEv2

  ike-proposal: ${IKE_PROPOSAL}
  esp-proposal: ${ESP_PROPOSAL}
  psk: ${PSK}

  local-sgw-ip: ${REMOTE_SGW_IP}
  # Yandex Cloud Security Gateway - ${SGW_NAME}
  yc-sgw-ip: ${YC_SGW_IP}
#

YC-prefixes: 
%{ for prefix in YC_SUBNETS ~}
  ${prefix}
%{ endfor ~}
