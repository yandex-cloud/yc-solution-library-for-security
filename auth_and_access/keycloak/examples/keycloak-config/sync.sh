#!/bin/bash

# Sync required input and output values 
# from keycloak-deploy to keycloak-config  

SRC_PATH="../keycloak-deploy"
SRC_FN=main.tf
DST_FN=main.tf

KC_FQDN=$(terraform -chdir=$SRC_PATH output -raw kc_fqdn)
KC_PORT=$(grep kc_port $SRC_PATH/$SRC_FN | awk -F "\"" '{print $2}')
KC_ADM_USER=$(grep kc_adm_user $SRC_PATH/$SRC_FN | awk -F "\"" '{print $2}')
KC_ADM_PASS=$(grep kc_adm_pass $SRC_PATH/$SRC_FN | awk -F "\"" '{print $2}')

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sed -i "s/kc_fqdn.*/kc_fqdn = \"$KC_FQDN\"/" $DST_FN
  sed -i "s/kc_port.*/kc_port = \"$KC_PORT\"/" $DST_FN
  sed -i "s/kc_adm_user.*/kc_adm_user = \"$KC_ADM_USER\"/" $DST_FN
  sed -i "s/kc_adm_pass.*/kc_adm_pass = \"$KC_ADM_PASS\"/" $DST_FN

elif [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/kc_fqdn.*/kc_fqdn = \"$KC_FQDN\"/" $DST_FN
  sed -i '' "s/kc_port.*/kc_port = \"$KC_PORT\"/" $DST_FN
  sed -i '' "s/kc_adm_user.*/kc_adm_user = \"$KC_ADM_USER\"/" $DST_FN
  sed -i '' "s/kc_adm_pass.*/kc_adm_pass = \"$KC_ADM_PASS\"/" $DST_FN
fi
