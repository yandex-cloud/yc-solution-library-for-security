# VM disk encryption in the cloud using YC KMS

## Description
- The solution allows you to encrypt the disk (except the boot disk) on a [Yandex Compute Cloud VM](https://cloud.yandex.ru/services/compute) using [Yandex Key Management Service](https://cloud.yandex.ru/services/kms) and [dm-crypt](https://en.wikipedia.org/wiki/Dm-crypt)+[LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup).
- Deployment of the solution and prerequisites is performed using an example Terraform script.

## Operating diagram
![Diagram](https://user-images.githubusercontent.com/85429798/131116794-8dd100e3-c024-4297-a39d-8d1482fc8ead.png)


## Description of the solution operation
- Pass data to the [cloud-init](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata#keys-processed-in-public-images) script when deploying a VM instance.
- Install the software: AWS CLI, cryptsetup-bin, curl.
- The SSH key created by Terraform is transmitted.
- A Bash script with the create argument is executed on the VM: a high entropy encryption key is created using the KMS [generateDataKey](https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey) method and then written to a disk in both a free-text and encrypted format.
- The second VM disk is encrypted and mounted based on the encryption key.
- The encrypted key is copied to [Yandex Object Storage](https://cloud.yandex.ru/services/storage) and deleted from the file system.
- A script with the "open" argument is added to the OS startup options to automatically mount the encrypted disk at reboot.
- At the time of mounting, the encryption key is downloaded from S3, decrypted, and then deleted from the file system when mounting is complete.

> All operations with KMS and Object Storage are performed using a service account token linked to the VM at its creation.

Description of script arguments:
- create: Creating a high entropy key using the KMS [generateDataKey] (https://cloud.yandex.ru/docs/kms/api-ref/SymmetricCrypto/generateDataKey) method.
- open: Mounting an encrypted disk to a decrypted object.
- close: Unmounting an encrypted device.
- erase: Deleting the source device.


## Prerequisites (configured using the Terraform script example):
- Install and configure [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart).
- Create a service account.
- Create a KMS key.
- Assign rights for the KMS key to the created service account (kms.keys.encrypterDecrypter).
- Create an Object Storage Bucket.
- Assign rights to the Object Storage Bucket to the created service account (storage.uploader, storage.viewer + BucketPolicy).
- Assign a service account to the VM.
- Install AWS CLI: `apt install awscli`
- Install cryptsetup: `apt install cryptsetup-bin`


## Launching the solution
- Download the files.
- Fill out the variables.tf file.
- Execute Terraform commands:

```
terraform init
terraform apply
```
## Deployment results
- Check the status of mounted objects:

```
lsblk
```

![Status](https://user-images.githubusercontent.com/85429798/131117114-d15f733e-8db8-4bdc-a3bf-082554a4e7cc.jpg)

- Check the disk encryption status:

```
cryptsetup status encrypted1
```
![Status](https://user-images.githubusercontent.com/85429798/131117237-bb081d75-3876-4970-9a2c-b52ae4161c55.jpg)

- Check the disk on another VM. To do this, create a snapshot of the disk:

![Snapshot](https://user-images.githubusercontent.com/85429798/131117342-0ef73d39-890b-49c4-888c-7ca43789356f.jpg)

- Create a VM with a disk based on a snapshot:
![Creating a VM](https://user-images.githubusercontent.com/85429798/131117386-e1e9e805-2412-48bd-be9e-41e4ee83eed9.png)

- Try mounting a disk:

```
sudo mount /dev/vdb /mnt
```
![Test result](https://user-images.githubusercontent.com/85429798/131117495-c2cc85d4-21c9-4578-9027-907bf6c9d0c2.jpg)
