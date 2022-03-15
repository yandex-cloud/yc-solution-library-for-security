# Fault-tolerant operation of PT Application Firewall based on Yandex.Cloud
Purpose of the demo: Install PT Web Application Firewall (hereinafter, PT WAF) in Yandex.Cloud in a fault-tolerant configuration.

## For a detailed workshop analysis, see the video:
[![image](https://user-images.githubusercontent.com/85429798/129480863-ef468a52-1191-4a23-9801-5e09c0de0cad.png)](https://www.youtube.com/watch?v=tnGuyIXNL6o)


## Table of Contents:
- Description
- Deployment
- Description of the steps of working with PT WAF
- Checking the traffic flow and fault tolerance
- Additional materials: configuring PT WAF clustering and Application Load Balancer 

## Description:
Steps to be completed during the workshop:
- Installing the infrastructure using Terraform (Infrastructure as a Code).
- Installation and basic configuration of PT WAF Cluster in two Yandex.Cloud availability zones.

Fault tolerance is provided by:
- Clustering of the PT WAF in Active-Active mode
- Balancing of traffic using External-LB Yandex.Cloud
- Using Cloud Function in Yandex.Cloud to monitor the status of PT WAFs and, if they fail, direct the traffic to applications — `BYPASS`.

#### Environment scenario:
It is assumed that in Yandex.Cloud, the client has already deployed an unsafe external scenario of publishing a VM, that is, a VM running web applications in two availability zones. It also runs an external network load balancer. 

> To implement the entire diagram from scratch, use the playbook in the from-scratch folder

#### Diagram before:
![Diagram](https://user-images.githubusercontent.com/85429798/127995744-e9213d79-6fca-49cd-a2bf-3cf7bead0c75.png)


#### Diagram after:
![Diagram](https://user-images.githubusercontent.com/85429798/127995787-9d547d0c-390c-4df7-8577-928607fb3d08.png)

![Diagram](https://user-images.githubusercontent.com/85429798/127995819-fdc647d8-9125-4acf-8708-4088b8c28826.png)


## Preparation and prerequisites
- Install and configure [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart).
- Install [Terraform](https://www.terraform.io/downloads.html ).
- Install [jq](https://macappstore.org/jq/).

## Deployment

#### Terraform deployment:

- Download an archive with files [pt_archive.zip](https://github.com/yandex-cloud/yc-architect-solution-library/blob/main/security-solution-library/unmng-waf-ptaf-cluster/main/pt_archive.zip).
- Go to the folder with files.
- Add relevant parameters to the variables.tf file (comments indicate the necessary yc commands to get the values).
- Execute the Terraform initialization command:
```
terraform init
```
- Execute the load-balancer import command:

```
terraform import yandex_lb_network_load_balancer.ext-lb $(yc load-balancer network-load-balancer list --format=json | jq '.[].id' | sed 's/"//g') 
```
- Execute the Terraform startup command:
```
terraform apply
```
- Enable NAT on *ext-subnet-a* and *ext-subnet-b* (so that PT WAF can go online for updates and activate the license).
- Assign the security group `app-sg` to the VM *app-a* and *app-b*.

[<img width="1135" alt="image" src="https://user-images.githubusercontent.com/85429798/126979165-eb4c9e6b-806d-401c-bec1-53f54cbecef1.png">](https://www.youtube.com/watch?v=IOYw4fdn69A)

##

## Steps for working with PT AF
Video instructions:

- Forward SSH ports to connect to PT AF servers (**needs to be executed in two different terminal windows**):
```
ssh -L 22001:192.168.2.10:22013 -L 22002:172.18.0.10:22013 -L 8443:192.168.2.10:8443 -L 127.0.0.2:8443:172.18.0.10:8443 -i ./pt_key.pem yc-user@$(yc compute instance list --format=json | jq '.[] | select( .name == "ssh-a")| .network_interfaces[0].primary_v4_address.one_to_one_nat.address '| sed 's/"//g') 
```
This opens the SSH terminal (broker machine) — leave it open.

## Configuring PT AF clustering 

### Setting up the master server
- Connect to ptaf-a: 
```
ssh -p 22001 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
```
- List the current DB password:
```
sudo wsc -c 'password list'  
```
- Execute the cluster autoconfiguring script: 
```
/home/pt/cluster.sh
```
### Setting up a Slave server
- Connect to ptaf-b: 
```
ssh -p 22002 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
```
- Set the DB password from the previous step:
```
sudo wsc -c 'password set <master password>' 
(it must be the same as the password on the master node) 
```
- Execute the cluster autoconfiguring script: 
```
/home/pt/cluster.sh
```
### Creating clusters

- First, run synchronization on the Slave server using the commands:
```
ssh -p 22002 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
sudo wsc
Enter 0 
config commit
```
- Wait for the message on the Slave server: `TASK: [mongo | please configure all other nodes of your cluster]`. After that, switch to the Master server and start syncing with similar commands:
```
ssh -p 22001 -i pt_key.pem yc-user@localhost -o StrictHostKeyChecking=no
sudo wsc
Enter 0 
config commit
```
> If the *config commit* command fails on the Master, apply the command again.

- Next, the configuration on the Master node stopped at the message: `TASK: [mongo | wait config sync on secondary nodes]`. Manually execute the command on the Slave node: `config sync`.

- On the Slave, run:
```
config sync 
```
- On the Master, run:
```
config sync
```
- On the Master, run:
```
mongo --authenticationDatabase admin -u root -p $(cat /opt/waf/conf/master_password) waf --eval 'c = db.sentinel; l = c.findOne({_id: "license"}); Object.keys(l).forEach(function(k) { if (l[k].ip) { delete l[k].ip; l[k].hostname = "yclicense.ptsecurity.ru" }}); c.update({_id: l._id}, l)'
```

[<img width="1041" alt="image" src="https://user-images.githubusercontent.com/85429798/127007705-3a727cec-07c9-4071-80ca-1631070f83f2.png">](https://www.youtube.com/watch?v=zuTxyEeM7Vg)


#### Configuring traffic processing

- Open in the browser: https://127.0.0.1:8443

- Enter the standard login **admin** and password **positive**, change the password, for example, to `P@ssw0rd`.

- Open the tab Configuration → Network → Gateways by clicking on the pencil icon (Edit). 
- On each of the gateways, select the **Active** option.
- On each of the gateways, on the **Network** tab, define the aliases `mgmt`, `wan`, `lan` for the `eth-ext1` interface.

- Create an upstream on the tab Configuration → Network → Upstreams:
- Name: `internal-lb`
- Backend Host: *enter the address of the Yandex.Cloud internal load balancer*
- Backend port: `80`

- Create a service on the tab Configuration → Network → Services:
- Name: `app`
- Net interface alias: `wan`
- Listen port: `80`
- Upstream: `internal-lb`

- Edit an existing *Any* web application on the Configuration → Security → Web Applications tab:
- Service: `app`

[![image](https://user-images.githubusercontent.com/85429798/127023351-f0731361-5ba5-429a-82e9-5cc3c14a6355.png)](https://www.youtube.com/watch?v=lCFnHanCSSE)


## Checking the traffic flow and fault tolerance
- Look at the external IP address of your external load balancer.
- Disable *ptaf-a* and make sure that the traffic is passing.
- Disable *app-a* and make sure that the traffic is passing.
- Disable *ptaf-b* and make sure that `BYPASS` applies and the traffic switches over directly to the internal load balancer.
- Turn on *ptaf-a*, *ptaf-b*, and make sure that traffic goes through *ptaf* again.

[![image](https://user-images.githubusercontent.com/85429798/127031813-f9460c50-2765-40d4-aa16-f66fc7fd70b7.png)](https://www.youtube.com/watch?v=DQYzXVKVVjg)


# Additional materials

## Setting up Yandex Application Load Balancer 

In this model, you can use [Yandex Application Load Balancer](https://cloud.yandex.ru/docs/application-load-balancer/).

There are detailed instructions on [enabling a virtual hosting](https://cloud.yandex.ru/docs/application-load-balancer/solutions/virtual-hosting)
(including integration with Certificate Manager to manage SSL certificates).

