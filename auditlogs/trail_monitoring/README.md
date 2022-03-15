## Monitoring Audit Trails and events in Yandex Cloud Monitoring

![image](https://user-images.githubusercontent.com/85429798/134897482-37c00391-7a01-48c1-9b78-bae7513b42d0.png)

![image](https://user-images.githubusercontent.com/85429798/134897506-79fbbffa-0537-4028-b1f3-132486127fdf.png)

### Description 
The solution includes recommendations how to monitor Audit Trails performance and its security events using [Yandex Monitoring](https://cloud.yandex.ru/services/monitoring).

- Audit Trails monitoring:
    - The status of the Trail object (Active or not Active).
    - Count of processed events (the presence of bursts).

- Monitoring of security events:
    - The list is presented below.

#### Audit Trails monitoring
- Go to Audit Trails → Monitoring → Open in Monitoring.
- Select the desired dashboard: Trails by status or Delivered events.
- Click the ellipsis, select "Create alert".
- Set up an alert according to the [documentation](https://cloud.yandex.ru/docs/monitoring/operations/alert/create-alert) for a certain threshold. For example, on the "Trails by status" dashboard, enter the condition: status is not equal to 1 in 5 minutes (once a second, Trail sends Metric 1 if alive).

![image](https://user-images.githubusercontent.com/85429798/134897575-762c94fc-e709-4aed-a143-ec512852b5da.png)

#### Monitoring events from Audit Trails
- Go to Audit Trails → Monitoring → Open in Monitoring → Metric Explorer.
- Generate a request to the desired metric from the list below, for example: "trail.processed_events_count"{folderId="b1gh4nansv4ebqqmeu7b", service="audit-trails", event_type="yandex.cloud.audit.compute.CreateInstance"}"
- Click the ellipsis → Create alert.
- Set up an alert according to the [documentation](https://cloud.yandex.ru/docs/monitoring/operations/alert/create-alert) for your threshold, for example: greater than 0.

![image](https://user-images.githubusercontent.com/85429798/134897649-90cedcfc-ba5f-4037-9278-a5fd58beb12d.png)


#### List of metrics related to Information Security
- UpdateSecurityGroup: Updating a security group.
- UpdateSecretAccessBindings: Assigning rights for a Lockbox secret.
- AddInstanceOneToOneNat: Adding a public IP address for a VM instance.
- RemoveInstanceOneToOneNat: Removing a public IP address from a VM instance.
- DeleteInstance: Deleting a VM instance.
- instancegroup.DeleteInstanceGroup: Deleting an instance group.
- CreateAccessKey: Creating an access key.
- CreateApiKey: Creating an API key.
- DeleteFederation: Deleting a federation.
- UpdateServiceAccountAccessBindings: Updating access bindings.
- DeleteSymmetricKey: Deleting a symmetric key.
- ScheduleSymmetricKeyVersionDestruction: Scheduling destruction of the symmetric key version.
- DeleteCloud: Deleting a cloud.
- DeleteFolder: Deleting a catalog.
- BucketAclUpdate: Updating an ACL bucket.
- BucketDelete: Deleting a bucket.
- BucketPolicyUpdate: Editing bucket access policies.
- CreateNetwork: Creating a cloud network.
- DeleteNetwork: Deleting a cloud network.

