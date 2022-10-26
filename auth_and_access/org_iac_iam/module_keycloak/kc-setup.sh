# Get KC data
source kc-data.sh

# Change Timezone
timedatectl set-timezone Europe/Moscow
# timedatectl | tee kctest.txt

# Install Packages
apt-get update && apt-get install -y unzip openjdk-17-jre
apt-get update && apt-get install -y unzip openjdk-17-jre

# Map KC_FQDN to the localhost for the simplify KC provisioning
echo "127.0.0.1 $KC_FQDN" >> /etc/hosts

# Move LE certificates onto the place
mkdir -p $KC_CERT_PATH
mv *.pem $KC_CERT_PATH

# Get Keycloak distro and put files to the right place
curl -sLO https://github.com/keycloak/keycloak/releases/download/$KC_VER/keycloak-$KC_VER.zip
unzip -q keycloak-$KC_VER.zip
rm -f keycloak-$KC_VER/bin/*.bat
mkdir -p /opt/keycloak
cp -R keycloak-$KC_VER/* /opt/keycloak
rm -rf keycloak-$KC_VER/ keycloak-$KC_VER.zip 

# Import configuration from realm config file
export PATH=$PATH:/opt/keycloak/bin
kc.sh build
kc.sh import --file=realm.json

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
sleep 3

# Waiting until KC has been started
while :; do
  curl -sf "https://$KC_FQDN:$KC_PORT" -o /dev/null && break
  sleep 10
done

# Create KC Users
kcadm.sh config credentials --server https://$KC_FQDN:$KC_PORT --realm master --user $KC_ADM_USER --password $KC_ADM_PASS

while read line; do
  user=$(echo $line | cut -f1 -d:)
  pass=$(echo $line | cut -f2 -d:)
  kcadm.sh create users -r $KC_REALM -s username="$user" -s enabled=true 
  kcadm.sh set-password -r $KC_REALM --username "$user" -p "$pass" 
  #sleep 2
done < $KC_USERS_FN
