# Интеграция Starboard с Yandex Cloud Container Registry с целью сканирования запущенных образов

[Starboard](https://aquasecurity.github.io/starboard/v0.14.0/) - это замечательный бесплатный инструмент, который позволяет: As a Kubernetes operator to automatically update security reports in response to workload and other changes on a Kubernetes cluster - for example, initiating a vulnerability scan when a new Pod is started or running CIS Benchmarks when a new Node is added.

Интеграция Starboard и [Yandex Cloud Container Registry](https://cloud.yandex.ru/docs/container-registry/) позволит выполнять автоматическое сканирование на уязвимости образов при старте новых подов.

В Yandex Cloud Managed Service for Kubernetes для аутентификации в Yandex Cloud Container Registry используется сервисный аккаунт, [назначенный на k8s ноду](https://cloud.yandex.ru/docs/managed-kubernetes/security/#sa-annotation) с ролью container-registry.images.puller. Однако Starboard для аутентификации в приватных регистри использует свой собственный механизм. 

Starboard умеет аутентифицироваться в различных приватных Container Registry и это описано в документации [Private Registries](https://aquasecurity.github.io/starboard/v0.14.0/integrations/private-registries/). Для этого он просто копирует себе [k8s image pull secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Это секрет, который содержит аутентификационные данные и назначается на поды для аутентификации в регистри. 

Для того, чтобы снабдить starboard operator необходимым секретом возможно использовать [аутентификацию в registry с помощью авторизованных ключей](https://cloud.yandex.ru/docs/container-registry/operations/authentication#sa-json) отдельного сервисного аккаунта. 

Для этого выполните следующие шаги:

1. Создайте сервисный аккаунт [через ui](https://cloud.yandex.ru/docs/iam/operations/sa/create) либо через cli:
```
yc iam service-account create --name yc-cr-starboard
```

2. Назначьте сервисному аккаунту роль **container-registry.images.puller** [через ui](https://cloud.yandex.ru/docs/iam/operations/sa/assign-role-for-sa) либо cli:
```
yc container registry add-access-binding \
  --service-account-name yc-cr-starboard \
  --role container-registry.images.puller
```

3. Создайте авторизованный ключ для сервисного аккаунта и сохраните его в файл [через ui](https://cloud.yandex.ru/docs/iam/operations/authorized-key/create) либо cli:
```
yc iam key create --service-account-name yc-cr-starboard --output authorized-key.json
```

4. Создайте k8s secret специальным образом для аутентификации с помощью [авторизованного ключа сервисного аккаунта](https://cloud.yandex.ru/docs/container-registry/operations/authentication#sa-json):
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  .dockerconfigjson: $(kubectl create secret docker-registry regcred --docker-server=cr.yandex --docker-username=json_key --docker-password="$(cat ./key.json)" --dry-run=client --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode | jq 'del(.auths."cr.yandex".auth)' | base64 )
kind: Secret
metadata:
  name: regcred
type: kubernetes.io/dockerconfigjson
EOF
```

<details>
<summary>Подробности формата secret..........⬇️</summary>
По умолчанию, если создавать docker secret согласно документации [Create a Secret by providing credentials on the command line](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line), например командой:
```
kubectl create secret docker-registry regcred --docker-server=cr.yandex --docker-username=json_key --docker-password="$(cat ./key.json)" --dry-run=client -o yaml
```
у вас на выходе образуется секрет со следующим форматом:
```
apiVersion: v1
data:
  .dockerconfigjson: {"auths":{"cr.yandex":{"username":"json_key","password":"something__","auth":"anNvbl9rZXk6ewogICAiaWQiOi..."}}}
kind: Secret
metadata:
  creationTimestamp: null
  name: regcred
type: kubernetes.io/dockerconfigjson
```

а для успешной аутентификации в starboard необходим другой формат *без второго поля auth*. Поэтому мы его отрезаем командой выше
</details>

5. Назначьте созданный секрет на необходимые нагрузки, которые скачивают образы с Yandex Cloud Container Registry
согласно документации [Create a Pod that uses your Secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret) либо назначьте этот секрет на default сервисный аккаунт примапленный к подам [Add ImagePullSecrets to a service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account)

6. После чего следуйте [стандартным инструкциям starboard](https://aquasecurity.github.io/starboard/v0.14.0/operator/getting-started/) по установке, настройке и использованию starboard operator. 

7. Результаты сканирований Starboard:
- можно анализировать вручную путем вычитывания CRD [vulnerability-report](https://aquasecurity.github.io/starboard/v0.14.0/crds/vulnerability-report/)
- можно визуализировать с помощью [octant и lens](https://aquasecurity.github.io/starboard/v0.14.0/integrations/octant/)
- можно разработать автоматизацию, которая будет считывать CRD vulnarebility report и отправлять их в SIEM, например [Yandex Managed Service for Elasticsearch](https://cloud.yandex.ru/services/managed-elasticsearch)
- анализировать на Security Dashboard с помощью [Cluster image scanning]((https://docs.gitlab.com/ee/user/application_security/cluster_image_scanning/)) в [Yandex Managed Service for GitLab](https://cloud.yandex.ru/services/managed-gitlab). 
