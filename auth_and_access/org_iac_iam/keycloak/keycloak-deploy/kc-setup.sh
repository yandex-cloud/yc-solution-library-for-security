# ===============================
# Keycloak VM provisioning script
# ===============================

# Get Keycloak input data
source kc-data.sh

# Change Timezone
timedatectl set-timezone Europe/Moscow

# Install Packages
apt-get update > /dev/null
apt-get install -y unzip openjdk-18-jre jq > /dev/null

# Install Yandex Cloud CLI (yc CLI)
YC_PATH="/opt/yc"
mkdir -p ${YC_PATH}
curl -s -O https://storage.yandexcloud.net/yandexcloud-yc/install.sh
chmod u+x install.sh
./install.sh -a -i ${YC_PATH}/ 2>/dev/null
ln -s ${YC_PATH}/bin/yc /usr/bin/yc
rm -f install.sh
sed -i "\$ a source ${YC_PATH}/completion.bash.inc" /etc/profile

# Configuring yc CLI
VM_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
FOLDER_ID=$(yc compute instance get $VM_ID --format=json | jq -r .folder_id )
CLOUD_ID=$(yc resource folder get $FOLDER_ID --format=json | jq -r .cloud_id)
yc config profile create default
yc config set cloud-id $CLOUD_ID
yc config set folder-id $FOLDER_ID
unset CLOUD_ID FOLDER_ID VM_ID

# Get Keycloak distro and put files to the right place
curl -sLO https://github.com/keycloak/keycloak/releases/download/$KC_VER/keycloak-$KC_VER.zip
unzip -q keycloak-$KC_VER.zip
rm -f keycloak-$KC_VER/bin/*.bat
mkdir -p /opt/keycloak
cp -R keycloak-$KC_VER/* /opt/keycloak
rm -rf keycloak-$KC_VER/ keycloak-$KC_VER.zip 

export PATH=$PATH:/opt/keycloak/bin
kc.sh build

# Get Let's Encrypt certificate from the YC Certificate Manager
# Let's Encrypt should validate certificate request within 30 minutes
mkdir -p $KC_CERT_PATH
status=None
while [ $status != 'ISSUED' ]
do
  status=$(yc cm certificate get --full --name=$KC_CERT_NAME --format=json | jq -r .status)
  echo $(date +'%H:%M:%S') $status
  sleep 60
done
yc cm certificate download --name=$KC_CERT_NAME --chain=$KC_CERT_PATH/$KC_CERT_PUB --key=$KC_CERT_PATH/$KC_CERT_PRIV > /dev/null


# Prepare systemd things
groupadd keycloak
useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak
chown -R keycloak:keycloak /opt/keycloak
chmod o+x /opt/keycloak/bin/

cat <<EOF > /lib/systemd/system/keycloak.service
[Unit]
Description=Keycloak Service
After=network.target

[Service]
User=keycloak
Group=keycloak
PIDFile=/var/run/keycloak/keycloak.pid
WorkingDirectory=/opt/keycloak
Environment="KEYCLOAK_ADMIN=$KC_ADM_USER"
Environment="KEYCLOAK_ADMIN_PASSWORD=$KC_ADM_PASS"
ExecStart=/opt/keycloak/bin/kc.sh start \\
  --db-url-database=$PG_DB_NAME \\
  --db-url-host=$PG_DB_HOST \\
  --db-username=$PG_DB_USER \\
  --db-password=$PG_DB_PASS \\
  --hostname=$KC_FQDN \\
  --hostname-strict=true \\
  --http-enabled=false \\
  --https-protocols=TLSv1.3,TLSv1.2 \\
  --https-port=$KC_PORT \\
  --https-certificate-file=$KC_CERT_PATH/$KC_CERT_PUB \\
  --https-certificate-key-file=$KC_CERT_PATH/$KC_CERT_PRIV \\
  --log-level=INFO

[Install]
WantedBy=multi-user.target
EOF

# Start Keycloak via systemd
systemctl daemon-reload
sleep 3
systemctl start keycloak
systemctl enable keycloak

# Remove KC admin credentials from the systemd unit after the first start
sed -i '/KEYCLOAK_ADMIN/d' /lib/systemd/system/keycloak.service
systemctl daemon-reload
