#!/bin/bash

# Generate list of KC users with passwords
# one line per user account:
# user001:pass1
# user002:pass2
# ...

# Getting input data from variables.tf
KC_USER_CNT=$(grep -A3 kc_user_count variables.tf | grep default | awk -F "\"" '{print $2}')
KC_USER_PFX=$(grep -A3 kc_user_prefix variables.tf | grep default | awk -F "\"" '{print $2}')
KC_USER_FN=$(grep -A3 kc_user_file variables.tf | grep default | awk -F "\"" '{print $2}')

rm -f $KC_USER_FN
for cnt in $(seq -w 001 $KC_USER_CNT)
do
  echo $KC_USER_PFX$cnt:$(openssl rand -base64 12 | awk '{print substr($0,0,12)}') >> $KC_USER_FN
done
