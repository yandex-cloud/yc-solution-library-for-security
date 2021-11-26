# osquery и kubequery в k8s
<span style="color: red"> MVP </span>

## Задача

Использовать **osquery** и **kubequery** в k8s кластере и отправлять результаты в SIEM (ELK, Splunk)

## Вводная

[Osquery](https://github.com/osquery/osquery) - инструмент, который позволяет получать информацию об ОС в формате [SQL запросов](https://osquery.io/schema/current/#file_events). 
Решаемые задачи: 
- [Query configs, OS/device settings, proccess, open ports, packets](https://github.com/osquery/osquery#what-is-osquery)
- [File Integrity Monitoring with osquery](https://osquery.readthedocs.io/en/stable/deployment/file-integrity-monitoring/)
- [Reading syslog with osquery](https://osquery.readthedocs.io/en/stable/deployment/syslog/)
- [Anomaly detection with osquery](https://osquery.readthedocs.io/en/stable/deployment/anomaly-detection/)
- др.

[Kubequery](https://github.com/Uptycs/kubequery) - инструмент от создателей osquery, который позволяет получать информацию из кластера k8s о действующей конфигурации:
- api ресурсы
- назначенные роли RBAC
- инфо о политиках
- инфо о секретах
- др.

## Проблемы

- **osquery не имеет примеров установки в k8s в виде daemonset в публичном доступе**
- **инструменты не имеют встроенной возможности отправки результатов в SIEM (ELK, Splunk)**

## Схема решения
Картинка с kubequry

указать откуда она

## Развертывание

### Osquery

#### Установка osquery в k8s
**Особенности установки в k8s**:
- Устанавливать osquery на k8s ноды логично в виде [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)  
- osquery для корректной работы необходимо иметь доступ к директории k8s ноды "/proc" и иметь установленный флаг [hostPID=true] (https://github.com/BishopFox/badPods/tree/main/manifests/hostpid), но как выяснилось в результате теста этого недостаточно и при обращении изнутри контейнера к хостовой директории /proc контейнер все равно имеет доступ только к своим процессам. Это связано с [особенностями /proc директории](https://stackoverflow.com/questions/47072586/docker-access-host-proc)
- По причине выше и результатам тестов было найдено решение: устанавливать контейнеру параметры: hostNetwork: true, hostPID: true, hostIPC: true, "hostPath:path: /" и выполнять из него chroot в хостовый namespace. Это влечет за собой риски связанные с привелигированным подом и выходом за пределы контейнера, которые могут быть минимизированы отдельным namespace с данным контейнером и правильным RBAC + policy engine, network policy, и др.  
Существуют 2 способа понизить привилегии контейнера:
    - устанавливать агент osquery не через k8s, а напрямую на ноды (трудности в администрировании)
    - одна команда [в статье](https://developer.ibm.com/articles/monitoring-containers-osquery/) упоминает, что справилась с этой задачей разработав свой кастомный extension используя [osquery-go](https://github.com/kolide/osquery-go/blob/master/README.md) и в нем изменили default folder с /proc на /host/proc тем самым требуется лишь монтирование данного фолдера без привелегий <span style="color: green"> Необходим research </span>  



**Установка компонентов osquery в k8s**
<details>
<summary>Развернуть для просмотра..........⬇️</summary>

**Подготовленная конфигурация включает**:
- основной конфиг osquery с включенным:
    - контролем целостности критичных k8s nodes файлов (согласно CIS Benchmark)
    - включенными [osquery packs](https://github.com/osquery/osquery/tree/master/packs): "incident response", "vuln-management"
- конфиг со скриптом, который проверяет наличие osquery бинарника на k8s ноде и при необходимости копирует его и запускает

**Прериквизиты**:
- развернутый кластер [Managed Service for Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/quickstart)


- скачайте файлы репозитория 
```
git clone https://github.com/yandex-cloud/yc-solution-library-for-security.git 
```
- перейдите в папку
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/osquery-install-daemonset/ 
```
- при необходимости кастомизируйте файлы: configmap-config.yaml, configmap-pack_conf.yaml
- выполните команду
```
kubectl apply -f ./ns.yaml 
kubectl apply -f ./
```
- <span style="color: red"> TBD: создание helm chart </span>

</details>

## 

#### Отправка результатов в SIEM
Отправка результатов в SIEM выполняется по схеме [Using a node logging agent](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-node-logging-agent)

##### Отправка результатов в ELK
<details>
<summary>Развернуть для просмотра..........⬇️</summary>  

Для отправки в ELK используется [filebeat](https://www.elastic.co/beats/filebeat). Filebeat имеет встроенный [модуль osquery](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-module-osquery.html). Устанавливается с помощью [helm-chart](https://github.com/elastic/helm-charts/tree/main/filebeat). 

<скрин>

**Прериквизиты**:
- развернутый кластер [Managed Service for Elasticsearch](https://cloud.yandex.ru/docs/managed-elasticsearch/operations/cluster-create)
- credentials от кластера

**Установка компонентов в k8s**
- перейдите в папку
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/filebeat-helm/
```
- скачайте сертификат Managed Elastic сервиса (общий для всех)
```
mkdir ~/.elasticsearch && \
wget  "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ~/.elasticsearch/root.crt && \
chmod 0600 ~/.elasticsearch/root.crt
cp ~/.elasticsearch/root.crt ./elastic-certificate.pem
```
- создать секрет с сертификатом ELK в кластере k8s 
```
kubectl create secret generic elastic-certificate-pem --from-file=./elastic-certificate.pem
```
- создать секрет с credentials ELK в кластере k8s (заменить на свои)
```
kubectl create secret generic security-master-credentials --from-literal=username=admin --from-literal=password=P@ssword
```
- подготовить существующий в папке файл ./values.yaml (отредактикровать)
```
задать имя elk хоста
extraEnvs:
    - name: "ELASTICSEARCH_HOSTS"
      value: "c-c9qfrs7u8i6g59dkb0vj.rw.mdb.yandexcloud.net:9200"
при необходимости поменять конфигурационный файл
```
- установить helm chart с указанием модифицированного helm файла values
```
helm repo add elastic https://helm.elastic.co

helm install filebeat elastic/filebeat -f values.yaml
```
- проверить наличие записей в базе ELK в индексе filebeat-osquery (создать index pattern)
-  <span style="color: red"> TBD: создание отделього dashboard в ELK для osquery (установленные пакеты, шел команды, открытые порты, версии ос и нод и т.д.) </span>

</details>

##### Отправка результатов в Splunk

<details>
<summary>Развернуть для просмотра..........⬇️</summary>  

Для отправки в Splunk используется [fluentd splunk hec plugin](https://github.com/splunk/fluent-plugin-splunk-hec). Устанавливается с помощью [helm-chart](https://github.com/splunk/splunk-connect-for-kubernetes/tree/develop/helm-chart/splunk-connect-for-kubernetes/charts/splunk-kubernetes-logging
). 

<скрин>

**Прериквизиты**:
- развернутый Splunk
- настроенный [HTTP Event Collector](https://docs.splunk.com/Documentation/SplunkCloud/8.2.2105/Data/UsetheHTTPEventCollector#Configure_HTTP_Event_Collector_on_Splunk_Enterprise)
- HEC Токен для отправки событий 

**Установка компонентов в k8s**
- перейдите в папку
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/fluentsplunk-helm/
```
- подготовить существующий в папке файл ./values.yaml (отредактикровать) либо [скачать исходный](https://github.com/splunk/splunk-connect-for-kubernetes/blob/develop/helm-chart/splunk-connect-for-kubernetes/charts/splunk-kubernetes-logging/values.yaml)

```
задать имя splunk хоста
splunk:
  hec:
    host: 51.250.7.127 (укажите ваше значение)
```
- установить helm chart с указанием файла ./values.yaml , вашего HEC Token и настройками SSL
```
helm install my-splunk-logging -f values.yaml --set splunk.hec.insecureSSL=true --set splunk.hec.token=20d504ff-269b-4443-953f-fb721c890d91 --set splunk-kubernetes-logging.fullnameOverride=splunk-logging https://github.com/splunk/splunk-connect-for-kubernetes/releases/download/1.4.5/splunk-kubernetes-logging-1.4.5.tgz
```

</details>

##

### Kubequery

#### Установка kubequery в k8s

**Особенности установки в k8s**:
Kubequery устанавливается в k8s в виде [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) с помощью [helm chart](https://github.com/Uptycs/kubequery#helm).  
Результаты kubequery записываются в папку пода: "/opt/uptycs/logs/osqueryd.results.log*".

Для отправки результатов работы kubequery в SIEM необходимо изменить конфигурацию helm chart путем добавления дополнительного sidecar container с агентом SIEM. Схема [Sidecar container with a logging agent](https://kubernetes.io/docs/concepts/cluster-administration/logging/#sidecar-container-with-a-logging-agent)  


##### Установка kubequery с filebeat sidecar для отправки в ELK

<details>
<summary>Развернуть для просмотра..........⬇️</summary>  

- перейдите в папку
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/kubequery/kubequery-with-elastic-filebeat/
```
- создайте namespace 
```
kubectl create ns kubequery
```
- скачайте сертификат Managed Elastic сервиса (общий для всех)
```
mkdir ~/.elasticsearch && \
wget  "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ~/.elasticsearch/root.crt && \
chmod 0600 ~/.elasticsearch/root.crt
cp ~/.elasticsearch/root.crt ./elastic-certificate.pem
```
- создать секрет с сертификатом ELK в кластере k8s 
```
kubectl create secret generic elastic-certificate-pem --from-file=./elastic-certificate.pem
```
- создать секрет с credentials ELK в кластере k8s (заменить на свои)
```
kubectl create secret generic security-master-credentials --from-literal=username=admin --from-literal=password=P@ssword
```
- указать в файле ./configmap-filebeat.yaml значение output.elasticsearch: hosts: "c-c9qfrs7u8i6g59dkb0vj.rw.mdb.yandexcloud.net:9200" (ваше значение)
- скачать файлы helm-chart командой
```
git clone https://github.com/Uptycs/kubequery.git
```
- копируем заготовленные файлы в папку чарта
```
cp ./*.yaml ./kubequery/charts/kubequery/templates/
```
- удаляем файл создания ns из папки чарта
```
rm ./kubequery/charts/kubequery/templates/namespace.yaml
```
- в файле ./kubequery/charts/kubequery/values.yaml указать значение имени кластера cluster: mycluster
- установить helm chart из локальной рабочей папки
```
helm install my-kubequery ./kubequery/charts/kubequery/ 
```
- <span style="color: red"> TBD: создание helm chart для удобства и contribute его в kubequery </span>

</details>

##### Установка kubequery с fluentd sidecar для отправки в Splunk

<details>
<summary>Развернуть для просмотра..........⬇️</summary>  

- перейдите в папку
```
cd /yc-solution-library-for-security/kubernetes-security/osquery-kubequery/kubequery/kubequery-with-splunk/
```
- создайте namespace 
```
kubectl create ns kubequery
```
- создаем секрет для хранения HEC токена
```
kubectl create secret generic splunk-hec-secret --from-literal=splunk_hec_token=706f58e0-73bf-4ca5-b9b3-f691a88e17b0 -n kubequery
```
- указать в файле ./configmap-fluentd.yaml значение hec_host "51.250.7.127" (ваш адрес) и host "my-cluster" (имя кластера)
- скачать helm-chart командой 
```
git clone https://github.com/Uptycs/kubequery.git
```
- копируем заготовленные файлы в папку чарта
```
cp ./*.yaml ./kubequery/charts/kubequery/templates/
```
- удаляем файл создания ns из папки чарта
```
rm ./kubequery/charts/kubequery/templates/namespace.yaml
```
- установить helm chart из локальной рабочей папки
```
helm install my-kubequery ./kubequery/charts/kubequery/ 
```
- <span style="color: red"> TBD: создание helm chart для удобства и contribute его в kubequery </span>

</details>