
! Cisco ASA with Routed mode (Tunnel) <-- IPSEC --> strongSwan Instance
! 
! Tested with Cisco ASAv v9.15(1)10
!
! Should be work with Cisco ASA/ASAv families 
!

!
crypto ikev2 enable outside
!
crypto ikev2 policy 1

 %{if IKE_PROPOSAL == "aes128gcm16-prfsha256-ecp256"}encryption aes-gcm%{ endif ~}
 %{if IKE_PROPOSAL == "aes192"}encryption aes-192%{ endif ~}
 %{if IKE_PROPOSAL == "aes"}encryption aes%{ endif ~}

 integrity null
 group 19
 prf sha256
!
crypto ipsec ikev2 ipsec-proposal IKE2-PROPOSAL

 %{if IKE_PROPOSAL == "aes128gcm16-prfsha256-ecp256"}protocol esp encryption aes-gcm%{ endif ~}
 %{if IKE_PROPOSAL == "aes192"}protocol esp encryption aes-192%{ endif ~}
 %{if IKE_PROPOSAL == "aes"}protocol esp encryption aes%{ endif ~}
 protocol esp integrity null
!
crypto ipsec profile IKE2-PROFILE
 set ikev2 ipsec-proposal IKE2-PROPOSAL
 set security-association lifetime kilobytes unlimited
 set security-association lifetime seconds 50000
!
group-policy IKE2-POLICY internal
group-policy IKE2-POLICY attributes
 vpn-tunnel-protocol ikev2
!
tunnel-group ${YC_SGW_IP} type ipsec-l2l
tunnel-group ${YC_SGW_IP} general-attributes
 default-group-policy IKE2-POLICY
!
tunnel-group ${YC_SGW_IP} ipsec-attributes
 ikev2 remote-authentication pre-shared-key ${PSK}
 ikev2 local-authentication pre-shared-key ${PSK}
!
interface Tunnel10
 nameif vti
 ip address 169.254.254.1 255.255.255.252
 tunnel source interface outside
 tunnel destination ${YC_SGW_IP}
 tunnel mode ipsec ipv4
 tunnel protection ipsec profile IKE2-PROFILE
!

! Route YC prefixes via IPsec Tunnel interface
%{ for SUBNET in YC_SUBNETS ~}
route vti ${split("/",SUBNET)[0]} ${cidrnetmask(SUBNET)} 169.254.254.2 1
%{ endfor ~}
