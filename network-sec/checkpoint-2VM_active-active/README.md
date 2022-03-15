# Two NGFW Check Points: Active-Active

![network_diagram_final](https://user-images.githubusercontent.com/85429798/139543124-cf9cbb90-1d90-4d29-95ed-8e9c5b29c30b.png)

![image](https://user-images.githubusercontent.com/85429798/139543134-1a9f3390-d3a2-4e67-b401-85a544c27e79.png)



## Solution description
Network segmentation using an NGFW Check Point in two availability zones (DC) in the **Active-Active** mode.

- The solution automatically creates several network segments in two availability zones (DC).
- It Installs and configures two NGFW Check Points in the Active-Active mode and the management server.
- Network communication between the zones is still possible and performed **without asymmetry**.
- **If one of the two firewalls in this availability zone fails, connectivity to the internet and other VPCs is lost**.
- For cross-zonal connectivity between VPCs, VPC Transit between two FWS is used. The traffic path from VPC Servers (zone A) to VPC Database (zone B): servers-a → FW-A → FW-B → database-b.

## Solution features (details)
- Create a separate folder and VPC for each network segment: Servers, Database, Mgmt, and several VPC-# stubs. Stubs are used because it won't be possible to add more interfaces to the VM afterwards. You can select VPC names at your discretion.
- Create networks and subnets for the VPC data according to the network diagram and the filled out variables.tf file.
- Create the necessary static cloud routes and assign them to VPC subnets.
- Create two FW VMs: [Check Point CloudGuard IaaS - Firewall & Threat Prevention BYOL](https://cloud.yandex.ru/marketplace/products/f2eb527bqp4f4ksht2af) and a VM instance with a management server: [Check Point CloudGuard IaaS - Security Management BYOL](https://cloud.yandex.ru/marketplace/products/f2e1si2qna6s0q01eda0). Both images have a trial period. When used in production, FW has a PAYG pay-as-you-go image, and for the management server you need to purchase a separate license from Check Point or use your on-premise license.
- ☑️ Set up FW using [cloud-config](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk165476 ) according to the diagram (interfaces, routes, passwords). That's why you don't need to run the First time wizard.
- ☑️ Create a test Windows machine for managing firewalls using Check Point SMS.

## Prerequisites:
- :white_check_mark: You have an account in Yandex.Cloud.
- :white_check_mark: You installed and configured [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart).
- :white_check_mark: You installed and configured Git.
- :white_check_mark: [Terraform](https://www.terraform.io/downloads.html) is installed.
- :white_check_mark: A cloud account with cloud administrator's rights.

## Deployment using Terraform
- Download all the files and go to the folder.
- Fill out the provider.tf file with your `cloud_id` and `token` (use an OAuth token or a service account key file). See details [here](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs).
- Fill out the variables.tf file. The file contains default values, but you can replace them with your own data (subnets, VPC name, folder name, and so on). Make sure to change the `cloud_id` parameter. Example:
```Python
//-------------For Terraform

variable "cloud_id" {
  default     = "Your cloud id" #yc config get cloud-id
}
//------------VPC List
//--VPC 1
variable "vpc_name_1" {
  default     = "servers" #choose your name for vpc-1
}

variable "subnet-a_vpc_1" {
  default = "10.160.1.0/24" #change if you need
}
variable "subnet-b_vpc_1" {
  default = "10.161.1.0/24" #change if you need
}
//--VPC 2
variable "vpc_name_2" {
  default     = "database" #choose your name for vpc-2
}

variable "subnet-a_vpc_2" {
  default = "10.160.2.0/24" #change if you need
}
variable "subnet-b_vpc_2" {
  default = "10.161.2.0/24" #change if you need
}
...

```

- Run the command:
```
terraform init
``` 
- Run the command:
```
terraform apply
``` 

- As a result, you will get outputs in the console:

```Python
Outputs:

a-external_ip_address_of_win-check-vm = "193.32.218.131" # address of the Windows VM for management purposes (log in, download the GUI console using the management server UI)
b-password-for-win-check = <sensitive> # The password for the Windows VM. To get it, run: terraform output b-password-for-win-check
c-ip_address_mgmt-server = "192.168.1.100" # management server IP address
d-ui_console_mgmt-server_password = "admin" # A default password for the management server UI
e-gui_console_mgmt-server_password = <sensitive> # a password to log in to the management server GUI console. To get it, run: terraform output e-gui_console_mgmt-server_password
f-sic-password = <sensitive> # A SIC password for communication between the management server and FW. To get it, run: terraform output f-sic-password
g-ip_address_fw-a = "192.168.1.10" # FW-A address
h-ip_address_fw-b = "192.168.2.10" # FW-B address
i-path_for_private_ssh_key = "./pt_key.pem" # An SSH key to connect to a Check Point VM
``` 
- Sequence of actions:
    - Connect to the Windows VM via RDP.
    - Connect via the browser to the management server address: enter the default login, password and change the password.
    - Download the GUI console from the UI.
    - Connect via the GUI to the management server: enter admin as a login, and e-gui_console_mgmt-server_password as a password.
    - Add both FWs to the management server using the SIC password.

## Requirements for production deployment
By the results of the test, follow the instructions to ensure security of your infrastructure:
- Be sure to change the passwords that were passed using the metadata service in the check-init...yaml and cloud-int_win...yaml files:
    - The password of the Windows VM administrator.
    - The password for the GUI console of the management server.
    - A SIC password to enable communication between the management server and the FW.
- Save the pt_key.pem SSH key to a secure location or recreate it separately on behalf of Terraform using your bastion tools.
- Delete the public address of the Windows VM.
- Set up ACL and NAT policies in the Check Point NGFW.
- Consider your cloud network specifics and don't assign public addresses using cloud tools to VM instances where the Check Point NGFW is specified as the default gateway. Details (https://cloud.yandex.ru/docs/vpc/concepts/static-routes#internet-routes).
- Select the appropriate license and image: either PAYG from the marketplace (for the FW) or BYOL with its license (for the management server).
