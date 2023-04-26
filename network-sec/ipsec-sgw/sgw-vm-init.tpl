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
  - content: |
      #!/bin/bash

      usermod -a -G docker ${ADMIN_NAME}

      # Get strongSwan container image version (tag)
      SWAN_VER=$(docker image ls strongswan --format "{{.Tag}}")

      # Create SGW container
      docker create --name=strongswan --hostname=strongswan --network=host \
        --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --cap-add=SYS_MODULE \
        --env REMOTE_SGW_IP="${REMOTE_SGW_IP}" \
        --env POLICY_NAME="${POLICY_NAME}" \
        --env IKE_PROPOSAL="${IKE_PROPOSAL}" \
        --env ESP_PROPOSAL="${ESP_PROPOSAL}" \
        --env PSK="${PSK}" \
      strongswan:$SWAN_VER
      docker start strongswan

      # Add ip routes via ipsec0 tunnel
      rlist="${ROUTE_LIST}"
      IFS=';'; IN=($rlist); unset IFS; 
      for r in "$${IN[@]}" ;  
      do 
        echo $r | tee -a /etc/rc.local
        echo $r | tee -a /root/add-routes.sh
      done

      # Prepare a shared volume for both containers
      mkdir -p /opt/webhc
      mount -t tmpfs tmpfs /opt/webhc -o size=1m

      # Create Web-HC container
      WEBHC_VER=$(docker image ls web-hc --format "{{.Tag}}")
      docker create --name=web-hc --hostname=web-hc \
        --network=host \
        --volume=/opt/webhc:/var/www/local \
      web-hc:$WEBHC_VER
      docker start web-hc

      # Schedule the IPsec tunnel status checker
      (echo "#* * * * * docker exec -it strongswan swanctl --list-conns | head -1 | awk '{split($0,a,":"); print a[1]}' | grep -q INSTALLED && touch /opt/webhc/status-ok || rm -f /opt/webhc/status-ok\"") | crontab -
    path: "/root/sgw-init.sh"
    permissions: "0740"
runcmd:
  - sleep 1
  - sudo -i
  - /root/sgw-init.sh
  - chmod +x /root/add-routes.sh
  - /root/add-routes.sh
