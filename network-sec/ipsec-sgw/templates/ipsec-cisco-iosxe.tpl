
! Cisco IOS-XE with Routed mode (Tunnel) <-- IPSEC --> strongSwan Instance
! 
! Tested with Cisco Catalyst 8000v (IOS-XE v17.06.02).
!
! Should be work with Cisco CSR 1000v, Cisco ASR 1000,
! Cisco ISR 4000 and other Cisco IOS-XE platforms.

!
crypto ikev2 proposal IKE2-PROPOSAL
 %{if IKE_PROPOSAL == "aes128gcm16-prfsha256-ecp256"}encryption aes-gcm-128%{ endif ~}
 %{if IKE_PROPOSAL == "aes128g"}encryption aes128g%{ endif ~}
 %{if IKE_PROPOSAL == "aes"}encryption aes%{ endif ~}

 prf sha256
 group 19
!
crypto ikev2 policy IKE2-POLICY 
 match fvrf any
 proposal IKE2-PROPOSAL
!
crypto ikev2 keyring IKE2-KEYS
 peer YC-SGW
  address ${YC_SGW_IP}
  pre-shared-key 0 ${PSK}
!
crypto ikev2 profile IKE2-PROFILE
 match identity remote any
 authentication remote pre-share
 authentication local pre-share
 keyring local IKE2-KEYS
 dpd 10 3 on-demand
!
crypto ipsec transform-set TS
%{~if ESP_PROPOSAL == "aes128gcm16"} esp-gcm 128%{ endif ~}
%{~if ESP_PROPOSAL == "aes"} aes 128%{ endif ~}

 mode tunnel
!
crypto ipsec profile IPSEC-PROFILE
 set transform-set TS
 set ikev2-profile IKE2-PROFILE
!
interface Tunnel10
 description == IPSEC-Tunnel ==
 ip unnumbered GigabitEthernet2
 tunnel source GigabitEthernet2
 tunnel mode ipsec ipv4
 tunnel destination ${YC_SGW_IP}
 tunnel protection ipsec profile IPSEC-PROFILE
!

! Route YC prefixes via IPsec Tunnel interface
%{ for SUBNET in YC_SUBNETS ~}
ip route ${split("/",SUBNET)[0]} ${cidrnetmask(SUBNET)} Tunnel10
%{ endfor ~}
