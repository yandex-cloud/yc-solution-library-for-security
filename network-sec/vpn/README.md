# Terraform and Security Groups Example 1
Mock web-application environment with security groups to provide secure remote-access and isolation

## Detailed analysis in the video
[![image](https://user-images.githubusercontent.com/85429798/128352799-3fd11416-dcc1-4f00-b67f-98d63be37580.png)](https://www.youtube.com/watch?v=MeJ8fTS2iGU&t=854s)


## Preliminary setup
- Fill out the terraform.tfvars_example file and rename it to terraform.tfvars.
- To the file, add your values of `cloud_id`, `folder_id`, and the `token`.
- In the variables.tf file, replace the value of the `remote_whitelist_ip` variable with your own list of public IP addresses from which it is allowed to connect to the network: each address in quotes, separated by a comma, for example: `default = ["1.1.1.1/32", "2.2.2.2/32"]`.
- In the same file, change the value of the `ipsec_password` to the desired password for the test IPsec connection.
- Run `terraform init`.
- Run `terraform apply`.

