# Packer template for building Yandex Image
Packer template for building all-in-one Wazuh image for Yandex cloud
## Preparing
Checkout wazuh rules 
```shell
cd ansible/roles/wazuh/files

git clone  --depth 1 --branch  v0.1.0 https://github.com/opennix-solutions/wazuh-yandex-cloud-rules.git rules

```
## Ansible variables 
`packages_to_install` - Deb packages for installation default:
```yanl
packages_to_install:
    - python3-pip
    - awscli
    - apt-transport-https
    - curl
    - lsb-release
    - unzip
    - wget
    - libcap2-bin
    - software-properties-common
    - gnupg2
    - net-tools
    - htop
```
`pip_packages_to_install` - Python libraries for installations default
```yaml

pip_packages_to_install:
    - docker==4.2.0
    - boto3
```
`wazuh_pip_packages` - List of packages for Wazuh internal python default:
```yaml

wazuh_pip_packages:
    - clamd
```
`clamav_packages` - List of ClamAv packages(optional) default
```yaml
clamav_packages:
    - clamav-daemon
    - clamav-freshclam
    - clamav
```
`wazuh_version` - Wazuh version default
```yaml
wazuh_version: "4.3"
```
`yandex_wazuh_app_url` - Custom Wazuh application for Yandex cloud
```yaml

yandex_wazuh_app_url: "https://artifacts.comcloud.xyz/wazuh-1.2.0.zip"
```
`local_mirror` - Use or Not ClamAv local mirror, default
```yaml

local_mirror: true
```
`local_mirror_url` - Local mirror domain name
```yaml

local_mirror_url: "clamav.comcloud.xyz"
```
`use_clamav` - Use integration between Yandex S3 and ClamAV default
```yaml
use_clamav: true
```
```yaml
yandex_wodle_url: url for Yandex wodle 
```
## How to build image
Export system variables

```shell

export YC_TOKEN=$(yc iam create-token)
export YC_FOLDER_ID=$(yc config get folder-id)

```
Run packer build 
```shell
packer build .
```
