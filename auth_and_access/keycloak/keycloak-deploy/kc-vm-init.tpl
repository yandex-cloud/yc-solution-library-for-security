#cloud-config
#ssh_pwauth: no
users:
  - name: ${username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - "${ssh_key}"