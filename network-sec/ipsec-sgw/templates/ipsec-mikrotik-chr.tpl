# ================================================
# Mikrotik CHR RouterOS 7.x
# https://help.mikrotik.com/docs/display/ROS/IPsec
# ================================================

# All IPsec firewall filters should be configured BEFORE ANY action=drop RULES !
/ip firewall filter
add action=accept chain=input comment="Allow UDP 500,4500 IPSec for YC peer" protocol=udp dst-port=500,4500 dst-address=${YC_SGW_IP}
add action=accept chain=input comment="Allow IPSec ESP for YC peer" protocol=ipsec-esp dst-address=${YC_SGW_IP}
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec


/ip ipsec profile add dh-group=ecp256 prf-algorithm=sha256 nat-traversal=yes proposal-check=obey name "IKE2-PROFILE" 
/ip ipsec proposal add auth-algorithms="" enc-algorithms=aes-128-gcm pfs-group=none lifetime=8h disabled=no name="IKE2-PROPOSAL"

/ip ipsec peer add address=${YC_SGW_IP} exchange-mode=ike2 passive=no send-initial-contact=yes profile="IKE2-PROFILE" disabled=no name="YC"
/ip ipsec identity add peer=YC auth-method=pre-shared-key remote-id=ignore secret="${PSK}"

# Policy routing via IPsec SA
/ip ipsec policy set 0 disabled=yes

%{ for PAIR in SUBNETS_PAIRS ~}
/ip ipsec policy add src-address=${PAIR.yc} dst-address=${PAIR.remote} tunnel=yes action=encrypt proposal=IKE2-PROPOSAL peer=YC
%{ endfor ~}


## Diagnostic & Monitoring
/ip ipsec proposal print
/ip ipsec profile print
/ip ipsec peer print
/ip ipsec identity print
/ip ipsec policy print

/ip ipsec active-peers print detail
/ip ipsec installed-sa print
