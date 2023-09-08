#cloud-config

datasource:
  Ec2:
    strict_id: false
ssh_pwauth: yes
users:
  - name: "${ADMIN_NAME}"
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh-authorized-keys:
      - "${ADMIN_SSH_KEY}"
write_files:
  - path: "/root/${KC_CERT_PUB}"
    permissions: "0644"
    content: "${KC_CERT_PUB_DATA}"
  - path: "/root/${KC_CERT_PRIV}"
    permissions: "0644"
    content: "${KC_CERT_PRIV_DATA}"
  - path: "/root/kc-init.sh"
    permissions: "0740"
    content: |
        #!/bin/bash

        # SSL certificates normalization for use
        base64 -d /root/${KC_CERT_PUB} > /root/pub.txt
        mv -f /root/pub.txt /root/${KC_CERT_PUB}
        base64 -d /root/${KC_CERT_PRIV} > /root/priv.txt
        mv -f /root/priv.txt /root/${KC_CERT_PRIV}

        echo "export KC_CERT_NAME=${KC_CERT_NAME}" > /root/kc_cert_name.sh

        usermod -a -G docker ${ADMIN_NAME}

        # Get Keycloak container image version (tag)
        KC_VER=$(docker image ls keycloak --format "{{.Tag}}")

        # Create Keycloak container
        docker create --name=keycloak --hostname=keycloak --network=host \
          --volume /etc/localtime:/etc/localtime:ro \
          --env KEYCLOAK_ADMIN="${KC_ADM_USER}" \
          --env KEYCLOAK_ADMIN_PASSWORD="${KC_ADM_PASS}" \
          --env KC_FQDN="${KC_FQDN}" \
          --env KC_PORT="${KC_PORT}" \
          --env PG_DB_HOST="${PG_DB_HOST}" \
          --env PG_DB_NAME="${PG_DB_NAME}" \
          --env PG_DB_USER="${PG_DB_USER}" \
          --env PG_DB_PASS="${PG_DB_PASS}" \
          --env KC_CERT_PUB="${KC_CERT_PUB}" \
          --env KC_CERT_PRIV="${KC_CERT_PRIV}" \
        keycloak:$KC_VER

        # Put SSL certificates to Keycloak container
        docker cp /root/${KC_CERT_PUB} keycloak:/opt/keycloak/conf/${KC_CERT_PUB}
        docker cp /root/${KC_CERT_PRIV} keycloak:/opt/keycloak/conf/${KC_CERT_PRIV}

        # Start Keycloak container
        docker start keycloak
runcmd:
  - sleep 1
  - sudo -i
  - /root/kc-init.sh
