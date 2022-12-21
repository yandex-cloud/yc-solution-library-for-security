$ORG_ID="bpfeqg5n2piooo2llm6m"
$CLOUD_IDs = (yc resource-manager cloud list --organization-id=$ORG_ID --format=json |  ConvertFrom-Json).id
foreach ($cloud in $CLOUD_IDs) { 
        (yc resource-manager cloud get --id=$cloud --format=json |  ConvertFrom-Json).name
        $FOLDER_IDs = (yc resource-manager folder list --cloud-id=$cloud --format=json | ConvertFrom-Json).id 
    foreach ($folder in $FOLDER_IDs) {
        (yc resource-manager folder get --id=$folder --format=json |  ConvertFrom-Json).name
        (yc vpc address list --cloud-id $cloud --folder-id $folder --format=json | ConvertFrom-Json).external_ipv4_address
        $IP_IDs = (yc vpc address list --cloud-id $cloud --folder-id $folder --format=json | ConvertFrom-Json).external_ipv4_address
    }
}
