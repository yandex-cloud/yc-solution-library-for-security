# Testing AntiDDos system using Yandex Load Testing
The solution allows you to test your AntiDDos system with [Yandex Load Testing](https://cloud.yandex.ru/docs/load-testing/)

**!!Important!!: Use this tool only to test your own infrastructure. Using a tool to load resources that are not yours may be a violation of the legislation of the Russian Federation and lead to negative consequences**

---

1) Prepare a test VM/service. For example, using the solution [Installing a Vulnerable Web Application (dvwa)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/vuln-mgmt/vulnerable-web-app-waf-test) or any other web service

2) Enable L7 DDos/Dos protection in Yandex Cloud using the service ["Yandex DDoS Protection: Extended protection"](https://cloud.yandex.ru/docs/vpc/ddos-protection/#advanced-protection) or enable protection from an external provider
---
(Extended protection works at levels 3 and 7 of the OSI model. In addition, you can track load indicators, attack parameters and connect Solidwall WAF in your Qrator Labs personal account. To enable advanced protection, contact your manager or technical support). Additionally, you can activate the WAF service (Web Application Firewall)

3) Ask your manager/architect/support to access the service [Yandex Load Testing](https://cloud.yandex.ru/docs/load-testing/)

4) Perform the initial setup of the service, agent according to the instructions [How to get started with Yandex Load Testing](https://cloud.yandex.ru/docs/load-testing/quickstart). 
--- 
The agent configuration is selected based on the desired load of requests per second (rps)
All available configurations [presented here](https://cloud.yandex.ru/docs/load-testing/concepts/agent) (10,000rps - small, 20,000 - medium 40,000 - large)

5) In the service menu, click **Create test** and select **Setting method** - Config

6) Insert the following configuration (load at 4000 rps):
```Python
phantom:
  enabled: true
  package: yandextank.plugins.Phantom
  address: your-test-app:80
  ammo_type: uri
  load_profile:
    load_type: rps
    schedule: step(75, 4000, 25, 2m)
  ssl: false
  uris:
    - /
core: {}
cloudloader:
  enabled: true
  package: yandextank.plugins.CloudUploader
  job_name: omgplease.tk
  job_dsc: ''
  ver: '1'
  api_address: loadtesting.api.cloud.yandex.net:443
```
!Need to change port 80 to 443 if using https

![Screen Shot 2022-03-30 at 11 22 21](https://user-images.githubusercontent.com/85429798/160808020-2c9378f2-d5b6-40d0-abae-d6fab197b272.png)

7) Click **Create**

8) As a result, a load test will start, the report of which can be viewed by failing into the test and selecting the **Report** button

![Screen Shot 2022-03-30 at 11 24 52](https://user-images.githubusercontent.com/85429798/160808048-c5e0306e-01c9-47fc-b1da-f66c1dc3d33a.png)

9) You will see an attack alert like **HTTP Misuse/Flood** on the target DDos protection system. HTTP attack. It is aimed at overloading the HTTP service with a large number of requests.



