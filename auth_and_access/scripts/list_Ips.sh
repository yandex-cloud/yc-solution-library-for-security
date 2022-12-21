export ORG_ID=yc.organization-manager.yandex
for CLOUD_ID in $(yc resource-manager cloud list --organization-id=${ORG_ID} --format=json | jq -r '.[].id');
do for FOLDER_ID in $(yc resource-manager folder list --cloud-id=$CLOUD_ID --format=json | jq -r '.[].id');
do yc vpc address list --cloud-id $CLOUD_ID --folder-id $FOLDER_ID --format=json | jq -r '.[].external_ipv4_address.address'
done;
done

