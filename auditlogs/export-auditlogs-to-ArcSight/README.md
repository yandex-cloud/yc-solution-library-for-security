# Collecting, monitoring, and analyzing audit logs in an external SIEM ArcSight
![Dashboard](https://user-images.githubusercontent.com/85429798/128209194-bc4eb274-1b97-4271-a712-e00a5f3f9b84.png)
![Scenarios](https://user-images.githubusercontent.com/85429798/128209212-a705f950-4eea-4305-8f21-decfc2ab7af0.png)

## Table of Contents

- [Collecting, monitoring, and analyzing audit logs in an external SIEM ArcSight](#)
  * [Solution description](#solution-description)
  * [Two log shipping scenarios](#two-log-shipping-scenarios)
  * [Solution diagram](#solution-diagram)
  * [Security Content](#security-content)
  * [Long-term storing of logs in S3](#long-term-storing-of-logs-in-s3)
  * [Instructions for scenarios](#instruction-for-scenarios)
      - [Prerequisites for scenarios](#prerequisites-for-scenarios)
      - [Scenario #1: Uploading log files to ArcSight from a server located inside the infrastructure of the customer's remote site](#prerequisites-for-scenarios)
      - [Scenario #2: Uploading log files to ArcSight using a VM located in Yandex.Cloud](#prerequisites-for-scenarios)
  * [Support and consulting services](#supportconsulting-services)


## Solution description
The current version of Security Content is available in the [repository](https://gitlab.ast-security.ru:14855/rodion/yandexcloudflex). Our support partner is ATB.
The solution lets you collect, monitor, and analyze audit logs in Yandex.Cloud from the following sources:

- [Yandex Audit Trails](https://cloud.yandex.ru/docs/audit-trails/)


## Two log shipping scenarios
- [x] Uploading log files to ArcSight from a server located inside the infrastructure of the customer's remote site

- [x] Uploading log files to ArcSight using a VM located in Yandex.Cloud


## Solution diagram
#### Scenario #1: Uploading log files to ArcSight from a server located inside the infrastructure of the customer's remote site
Description: 
- JSON files with logs are stored in S3.
- The s3fs utility is installed on a server in the customer's infrastructure, which allows you to mount an S3 Bucket as a local folder in your OS.
- A standard ArcSight Connector is installed on a server in the customer's infrastructure.
- Security content is loaded from the current repository.
- ArcSight Connector uses security content to read files, parses the files, and sends them to the ArcSight server.

![Diagram](https://user-images.githubusercontent.com/85429798/128553857-a6837742-8e63-4d8c-967a-be92454a0cb0.png)


#### Scenario #2: Uploading log files to ArcSight using a VM located in Yandex.Cloud
 
![Diagram](https://user-images.githubusercontent.com/85429798/128553811-2d25dcc7-0500-446b-96ea-35a8fe8959ba.png)


## Security Content
Security Content - ArcSight objects that are loaded according to the instructions. All the content has been developed together with our partner ATB, leveraging the long-term expertise of the Yandex.Cloud Security team and our cloud customers.

The current version of Security Content is available [here](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ArcSight/arcsight_content).

The solution contains the following Security Content:
- Parsing file (and map file).
- Dashboard that shows useful statistics.
- A set of Filters, Active channels, Active lists.
- A set of correlation Rules. [Detailed description of the list of correlation rules](./Use-cases.docx ) (the client should specify the alert destination).
All relevant event fields have been converted to a [Common Event Format](https://community.microfocus.com/cyberres/productdocs/w/connector-documentation/38809/arcsight-common-event-format-cef-implementation-standard).

For a detailed description of field mapping, see the file [Поля ArcSight_JSON.docx](https://gitlab.ast-security.ru:14855/rodion/yandexcloudflex/blob/master/Поля%20ArcSight_JSON.docx).


## Long-term storage of logs in S3
By default, these instructions suggest deleting files after reading, but you can both store Audit Trails audit logs in S3 on a long-term basis and send them to ArcSight.
For this you need to create two Audit Trails in different S3 buckets:
- The first bucket will be used only for storage.
- The second bucket will be used for integration with ArcSight.


## Instructions for scenarios
#### Prerequisites for scenarios
- :white_check_mark: Object Storage Bucket for Audit Trails ([instructions](https://cloud.yandex.ru/docs/storage/quickstart)).
- :white_check_mark: Audit Trails service enabled in the UI ([instructions](https://cloud.yandex.ru/docs/audit-trails/quickstart)).


#### Scenario #1: Uploading log files to ArcSight from a server located inside the infrastructure of the customer's remote site
1) Install the s3fs utility on the server inside the remote site infrastructure and prepare it for operation [follow the instructions](https://cloud.yandex.ru/docs/storage/tools/s3fs). Result: an Object Storage Bucket mounted as a folder and hosting Audit Trails JSON files. For example, `/var/trails/`.

2) Install ArcSight SmartConnector (FlexAgent — JSON Folder Follower) software on your server [follow the official instructions](https://www.microfocus.com/documentation/arcsight/arcsight-smartconnectors/AS_smartconn_install/).

3) During the installation, select *ArcSight FlexConnector JSON Folder Follower* and specify the previously mounted `/var/trails/` folder.

4) Specify the JSON configuration filename prefix: `yc`.

5) Complete the connector installation. 

6) Download all Security Content files from [here](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/auditlogs/export-auditlogs-to-ArcSight/arcsight_content).

7) Copy the yc.jsonparser.properties file to the `<agent installation folder >/current/user/agent/flexagent`.

8) Copy the file map.0.properties in `<agent installation folder>/current/user/agent/map`.

9) Edit the file `<agent installation folder>/current/user/agent/agent.properties`:
```
agents[0].mode=DeleteFile
agents[0].proccessfoldersrecursively=true
```

10) Start the connector and make sure that events are arriving
![Events](https://user-images.githubusercontent.com/85429798/128209247-c1582fc9-ea2a-4908-9c95-618ac1a097ee.png)


## Support and consulting services
Our support partner, ATB, provides the following services on a paid basis:
- Installing and configuring the connector.
- Connecting new data sources with security events.
- Developing new correlation rules and visualization tools.
- Developing mechanisms for responding to incidents.

Partner's contact details:
+7 (499) 648-75-48
info@ast-security.ru

![image](https://user-images.githubusercontent.com/85429798/128419821-aa2a4c85-7c67-4173-b21b-f0ec6b96e9e3.png)
