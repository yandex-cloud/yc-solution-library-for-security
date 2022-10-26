#!/bin/bash

# Local constants
DNS_CH_TYPE="CNAME"

# Getting input data from variables.tf
DNS_FOLDER_ID=$(grep -A3 folder_id variables.tf | grep default | awk -F "\"" '{print $2}')
KC_FQDN=$(grep -A3 kc_fqdn variables.tf | grep default | awk -F "\"" '{print $2}')
KC_HOST=$(echo $KC_FQDN | awk -F "." '{print $1}')
DNS_ZONE_NAME=$(grep -A3 dns_zone_name variables.tf | grep default | awk -F "\"" '{print $2}')

LE_CERT_NAME=$(grep -A3 le_cert_name variables.tf | grep default | awk -F "\"" '{print $2}')
LE_CERT_DESCR=$(grep -A3 le_cert_descr variables.tf | grep default | awk -F "\"" '{print $2}')
LE_CERT_PUB_KEY_FN=$(grep -A3 le_cert_pub_key variables.tf | grep default | awk -F "\"" '{print $2}')
LE_CERT_PRIV_KEY_FN=$(grep -A3 le_cert_priv_key variables.tf | grep default | awk -F "\"" '{print $2}')

# Ensure certificate name is not already exists at Certificate Manager
yc cm certificate get --name=$LE_CERT_NAME > /dev/null 2>&1
if [ $? == 0 ] 
  then
    echo -e "$LE_CERT_NAME name is already exists at Certificate Manager!\n";
    exit 1;
fi

echo -e " Request Let's Encrypt certificate for domain: $KC_FQDN\n"
yc cm certificate request --name=$LE_CERT_NAME --description="$LE_CERT_DESCR" --domains=$KC_FQDN --challenge=dns
if [ $? != 0 ] 
  then
    exit 1;
fi
sleep 8

# Taking an DNS Challenge from certificate for domain ownership validation.
# DNS Challenge validation can be TXT or CNAME type.
DNS_CHALLENGE=$(yc cm certificate get --full --name=$LE_CERT_NAME --format=json | jq -r '.challenges[].dns_challenge | select(.type | contains('\"$DNS_CH_TYPE\"')).value')

echo "Create DNS Challenge record at Cloud DNS"
yc dns zone add-records --folder-id=$DNS_FOLDER_ID --name=$DNS_ZONE_NAME --record="_acme-challenge.$KC_HOST 200 $DNS_CH_TYPE $DNS_CHALLENGE"

# Waiting for DNS Challenge validation process completed successfully
status=None
while [ $status != 'ISSUED' ]
do
  status=$(yc cm certificate get --full --name=$LE_CERT_NAME --format=json | jq -r .status)
  echo $(date +'%H:%M:%S') $status
  sleep 60
done

#echo "Remove DNS Challenge record from Cloud DNS"
#yc dns zone delete-records --folder-id=$DNS_FOLDER_ID --name=$DNS_ZONE_NAME --record="_acme-challenge.$KC_HOST 200 $DNS_CH_TYPE $DNS_CHALLENGE"

echo "Download Let's encrypt certificates from Certificate Manager"
yc cm certificate content --name=$LE_CERT_NAME --chain=$LE_CERT_PUB_KEY_FN --key=$LE_CERT_PRIV_KEY_FN > /dev/null
