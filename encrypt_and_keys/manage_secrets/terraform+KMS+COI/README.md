# Encrypting secrets with KMS when transferring the keys to the COI VM container Yandex.Cloud: Terraform

## Problems
After deploying containers using [Container Optimized Image (COI)](https://cloud.yandex.ru/docs/cos/concepts/), sometimes you might need to transfer private information inside the container using ENV.
In the UI console, in this case, in the VM properties, the transmitted ENV will be visible as plain text. There is a risk of compromising private information.

Example of an unsafe configuration:

![Unsafe configuration](https://user-images.githubusercontent.com/85429798/129485848-09fb4847-7ff6-46cd-be4a-990de7e41781.png)


## Example of secure transfer of private information to a COI container:
Yandex Cloud KMS supports the option to [encrypt secrets in Terraform](https://cloud.yandex.ru/docs/kms/solutions/terraform-secret).
We suggest using this function to transfer encrypted secrets to a container in the ENV format before they are decrypted inside a Python application.
Decryption of secrets from the Python code will be performed using a service account linked to the COI VM with the KMS Decrypter role. The token of the service account will be obtained using the [meta-date service](https://cloud.yandex.ru/docs/compute/operations/vm-info/get-info#inside-instance). 

The Terraform example performs:
- Testing of infrastructure deployment: networks, subnets.
- Creation of a test service account and its static keys.
- Deploying a COI with a container based on a simple Python application.
- Creating a KMS key and encrypting private data: in this case, encryption of static keys of the service account.
Private data is transmitted to the container in an encrypted form.

A simple Python application inside the code decrypts private data and prints data to the log.

**Important:** 
> This solution does not eliminate the need to apply the best practices of protecting the Terraform configuration.
> Yandex Cloud Object Storage can act as a Terraform Remote State and perform blocking functions using Yandex Database: https://github.com/yandex-cloud/examples/tree/master/terraform-ydb-state 

## Preparation and prerequisites
- Install and configure [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart).
- Install [Terraform](https://www.terraform.io/downloads.html ).
- Fill out the variables.tf file with your own data.
- Launch Terraform.

## Deployment results

In the UI console, we see secrets only in an encrypted form:

![Safe configuration](https://user-images.githubusercontent.com/85429798/129485922-ceff4208-c562-4021-8cc3-ddf0f0d927ec.png)


In the container logs, we see decrypted secrets:

![Safe configuration](https://user-images.githubusercontent.com/85429798/129485886-ca56bc93-4f86-45b1-ad99-c48de55bde6d.png)
