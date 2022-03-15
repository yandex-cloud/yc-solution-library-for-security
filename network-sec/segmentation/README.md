# Terraform and Security Groups Example 2
Mock dev/stage/prod environment with sample security groups to provide isolation

## Detailed analysis in the video
[![image](https://user-images.githubusercontent.com/85429798/128601756-b790bab4-0be5-4843-bc79-b15187023955.png)](https://www.youtube.com/watch?v=MeJ8fTS2iGU&t=854s)


## Preliminary setup
- Fill out the terraform.tfvars_example file and rename it to terraform.tfvars.
- To the file, add your values of `cloud_id`, `folder_id` for all the four folders, and the `token`.
- In the variables.tf file, replace the value of the `bastion_whitelist_ip` variable with your own list of public IP addresses from which it is allowed to connect to the network: each address in double quotes, separated by a comma, for example: `default = ["1.1.1.1/32", "2.2.2.2/32"]`.
- Run `terraform init`.
- Run `terraform apply`.
