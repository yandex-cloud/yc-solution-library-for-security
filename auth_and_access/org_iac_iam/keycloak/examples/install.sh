#!/bin/bash

REPO="https://raw.githubusercontent.com/yandex-cloud/yc-solution-library-for-security/master/auth_and_access/org_iac_iam/keycloak"

mkdir -p keycloak/keycloak-deploy
mkdir -p keycloak/keycloak-config

FILES="examples/env-yc.sh keycloak/env-yc.sh
examples/keycloak-deploy/main.tf keycloak/keycloak-deploy/main.tf
examples/keycloak-deploy/variables.tf keycloak/keycloak-deploy/variables.tf
examples/keycloak-config/main.tf keycloak/keycloak-config/main.tf
examples/keycloak-config/sync.sh keycloak/keycloak-config/sync.sh"

echo "$FILES" | while read URL FILE; 
do 
  curl -sl "$REPO/$URL" -o "$FILE"
done
