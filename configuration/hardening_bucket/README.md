## Example of a secure configuration for Yandex Cloud Object Storage: Terraform

#### Solution diagram
![Diagram](https://user-images.githubusercontent.com/85429798/136698539-f7772475-cca7-4498-8c79-426fc385a90f.png)


#### Description 
Terraform script performs the following:
- :white_check_mark: Creates a [Bucket](https://cloud.yandex.ru/docs/storage/concepts/bucket).
- :white_check_mark: Enables ([IAM](https://cloud.yandex.ru/docs/storage/security/) access control, [BucketPolicy](https://cloud.yandex.ru/docs/storage/concepts/policy)) for groups: administrators, read-only, write-only.
- :white_check_mark: Enables [versioning](https://cloud.yandex.ru/docs/storage/concepts/versioning) and [life cycle](https://cloud.yandex.ru/docs/storage/concepts/lifecycles) to store the current file versions for 365 days, and **non**-current file versions (deleted or updated) for 150 days.
- :white_check_mark: Enables [logging](https://cloud.yandex.ru/docs/storage/operations/buckets/enable-logging) actions on the Bucket in a separate Bucket.
- :white_check_mark: Enables Server-Side object [encryption](https://cloud.yandex.ru/docs/storage/operations/buckets/encrypt) in the Bucket.

#### Terraform details 
The solution accepts the following input:
- A list of administrator accounts: all-access-users.
- A list of service accounts requiring read rights: read-only-sa.
- A list of service accounts that require write rights: write-only-sa.

Functionality:
- Create an SA with Storage Admin rights to create a Bucket.
- Create a KMS key for encryption.
- Assign rights to accounts to work with KMS keys.
- Assign IAM rights to accounts to work with a Bucket.
- Create a separate Bucket for actions logging.
- Create the main Bucket.
- Apply the BucketPolicy.
- Enable versioning and lifecycle.
- Enable logging.
- Enable encryption.

#### Example of filling out variables:
```Python
variable "token" {
  description = "Yandex.Cloud security OAuth token"
  default     = "key.json" # generate yours: https://cloud.yandex.ru/docs/iam/concepts/authorization/OAuth-token
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID where resources will be created"
  default     = "xxxxxx" # yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex.Cloud ID where resources will be created"
  default     = "xxxxxx" #yc config get cloud-id
}

variable "all-access-users" {
  description = ""
  default = ["federatedUser:ajesnkfkxxxxxxxxxxxx", "federatedUser:ajeurmedxxxxxxxxxxxx"]

}

variable "read-only-sa" {
  description = ""
  default = ["serviceAccount:ajeph8f8xxxxxxxxxxxx", "serviceAccount:aje066slxxxxxxxxxxxx"]

}

variable "write-only-sa" {
  description = "sa"
  default = ["serviceAccount:ajem3ef7xxxxxxxxxxxx", "serviceAccount:aje1ngf4xxxxxxxxxxxx"]

}
```
