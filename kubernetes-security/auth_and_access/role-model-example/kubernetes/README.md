# Управление политиками

## Подготовим окружение

Для начала рекомендуется изучить [статью](https://labs.bishopfox.com/tech-blog/bad-pods-kubernetes-pod-privilege-escalation) в которой описаны возможные способы экплуатировать кластер с подами, в которых повышены привилегии.

От таких подов мы и будем защищатся.
Сначала попробуем создать такие поды в дефолтном кластере. В директории ./bad-pods есть поды и деплойменты с привилегиями из статьи


```
$ yc managed-kubernetes cluster get-credentials --id $(terraform output  -json | jq -r .cluster_id.value) --context-name devops --external --profile=demo-devops-user1 --force

$ kubectl apply -f ./bad-pods/pods
```

И убедимся что все успешно создалось. 

```
nrkk-osx:staging nrkk$ kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
everything-allowed-exec-pod   1/1     Running   0          8s
hostipc-exec-pod              1/1     Running   0          8s
hostnetwork-exec-pod          1/1     Running   0          8s
hostpath-exec-pod             1/1     Running   0          8s
hostpid-exec-pod              1/1     Running   0          8s
nothing-allowed-exec-pod      1/1     Running   0          8s
priv-and-hostpid-exec-pod     1/1     Running   0          8s
priv-exec-pod                 1/1     Running   0          8s
```

Удалим поды:

```
$ kubectl delete -f ./bad-pods/pods
```

# Установим pod security policies от kyverno

Установим kyverno с набором политик default , который будет блокировать нам плохие поды.

```
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace --set validationFailureAction=enforce
kubectl apply -f ./bad-pods/pods
```

Посмотрим на созданные политики.
Политики из профиля default доступны [в директории kyverno-policies](./kyverno-policies/)

```
$ kubectl get clusterpolicies.kyverno.io
NAME                             BACKGROUND   ACTION
disallow-add-capabilities        true         enforce
disallow-host-namespaces         true         enforce
disallow-host-path               true         enforce
disallow-host-ports              true         enforce
disallow-privileged-containers   true         enforce
disallow-selinux                 true         enforce
require-default-proc-mount       true         enforce
restrict-apparmor-profiles       true         enforce
restrict-sysctls                 true         enforce
```

Увидим что создался только *nothing-allowed-exec-pod*, а остальное поличло ошибки

```
$ kubectl apply -f ./bad-pods/pods
```

```
Error from server: error when creating "../../kubernetes/bad-pods/pods everything-allowed-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/everything-allowed-exec-pod was blocked due to the following policies

disallow-host-namespaces:
  host-namespaces: 'validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must not be set to true. Rule host-namespaces failed at path /spec/hostIPC/'
disallow-host-path:
  host-path: 'validation error: HostPath volumes are forbidden. The fields spec.volumes[*].hostPath must not be set. Rule host-path failed at path /spec/volumes/0/hostPath/'
disallow-privileged-containers:
  priviledged-containers: 'validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must not be set to true. Rule priviledged-containers failed at path /spec/containers/0/securityContext/privileged/'

Error from server: error when creating "../../kubernetes/bad-pods/hostipc-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/hostipc-exec-pod was blocked due to the following policies

disallow-host-namespaces:
  host-namespaces: 'validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must not be set to true. Rule host-namespaces failed at path /spec/hostIPC/'

Error from server: error when creating "../../kubernetes/bad-pods/hostnetwork-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/hostnetwork-exec-pod was blocked due to the following policies

disallow-host-namespaces:
  host-namespaces: 'validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must not be set to true. Rule host-namespaces failed at path /spec/hostNetwork/'

Error from server: error when creating "../../kubernetes/bad-pods/hostpath-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/hostpath-exec-pod was blocked due to the following policies

disallow-host-path:
  host-path: 'validation error: HostPath volumes are forbidden. The fields spec.volumes[*].hostPath must not be set. Rule host-path failed at path /spec/volumes/0/hostPath/'

Error from server: error when creating "../../kubernetes/bad-pods/hostpid-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/hostpid-exec-pod was blocked due to the following policies

disallow-host-namespaces:
  host-namespaces: 'validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must not be set to true. Rule host-namespaces failed at path /spec/hostPID/'

Error from server: error when creating "../../kubernetes/bad-pods/priv-and-hostpid-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/priv-and-hostpid-exec-pod was blocked due to the following policies

disallow-host-namespaces:
  host-namespaces: 'validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must not be set to true. Rule host-namespaces failed at path /spec/hostPID/'
disallow-privileged-containers:
  priviledged-containers: 'validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must not be set to true. Rule priviledged-containers failed at path /spec/containers/0/securityContext/privileged/'

Error from server: error when creating "../../kubernetes/bad-pods/priv-exec-pod.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Pod/default/priv-exec-pod was blocked due to the following policies

disallow-privileged-containers:
  priviledged-containers: 'validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must not be set to true. Rule priviledged-containers failed at path /spec/containers/0/securityContext/privileged/'

```

Создадим еще деплойменты , чтобы увидеть как тут работают политики.

```
$ kubectl apply -f ./bad-pods/deployments/
```

Деплойменты создались, а вот поды в них не создались. Потому что при попытке создать под, деплоймент получает такую же ошибку, какую получили бы мы создав под напрямую. Детально ошибку можно увидеть сделать kubectl describe
```
nrkk-osx:staging nrkk$ kubectl get deploy
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
everything-allowed-exec-deployment   0/2     0            0           29s
hostipc-exec-deployment              0/2     0            0           29s
hostnetwork-exec-deployment          0/2     0            0           29s
hostpath-exec-deployment             0/2     0            0           28s
hostpid-exec-deployment              0/2     0            0           28s
nothing-allowed-exec-deployment      2/2     2            2           28s
priv-and-hostpid-exec-deployment     0/2     0            0           28s
priv-exec-deployment                 0/2     0            0           27s
```

Удалим kyverno:

```
$ kubectl delete -f ./bad-pods/deployments/
$ kubectl delete -f ./bad-pods/pods/
$ helm delete kyverno  --namespace kyverno 
```
## Open Policy Agent Gatekeeper

Установим OPA Gatekeeper:

```
$ helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
$ helm repo update
$ helm install gatekeeper gatekeeper/gatekeeper --namespace gatekeeper --create-namespace
```

Так библиотеку шаблонов политик, доступных в gatekeper. При помощи kustomize установим все шаблоны в кластер:

```
$ curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

# проверьте тут что kustomize просто положит бинарный файл в текущую директорию

$ ./kustomize build https://github.com/open-policy-agent/gatekeeper-library/library | kubectl apply -f -
```

Применим политики gatekeeper для защиты от bad pods.

```
$ kubectl apply -f ./gatekeeper-policies/
```

Проверим что у кластере есть 
1) Шаблоны политик
```
$ kubectl get constrainttemplates
NAME                                      AGE
k8sallowedrepos                           20h
k8sblocknodeport                          20h
k8scontainerlimits                        20h
k8shttpsonly                              20h
k8simagedigests                           20h
k8spspallowedusers                        20h
k8spspallowprivilegeescalationcontainer   20h
k8spspapparmor                            20h
k8spspcapabilities                        20h
k8spspflexvolumes                         20h
k8spspforbiddensysctls                    20h
k8spspfsgroup                             20h
k8spsphostfilesystem                      20h
k8spsphostnamespace                       20h
k8spsphostnetworkingports                 20h
k8spspprivilegedcontainer                 20h
k8spspprocmount                           20h
k8spspreadonlyrootfilesystem              20h
k8spspseccomp                             20h
k8spspselinuxv2                           20h
k8spspvolumetypes                         20h
k8srequiredlabels                         20h
k8srequiredprobes                         20h
k8suniqueingresshost                      20h
k8suniqueserviceselector                  20h
```

2) Сами политки

```
$ kubectl get constraints
NAME                                                                 AGE
k8spsphostfilesystem.constraints.gatekeeper.sh/psp-host-filesystem   20h

NAME                                                                           AGE
k8spspprivilegedcontainer.constraints.gatekeeper.sh/psp-privileged-container   20h

NAME                                                                     AGE
k8spspforbiddensysctls.constraints.gatekeeper.sh/psp-forbidden-sysctls   20h

NAME                                                                         AGE
k8spsphostnetworkingports.constraints.gatekeeper.sh/psp-host-network-ports   20h

NAME                                                               AGE
k8spsphostnamespace.constraints.gatekeeper.sh/psp-host-namespace   20h

NAME                                                       AGE
k8spspprocmount.constraints.gatekeeper.sh/psp-proc-mount   20h
```

Создадим плохие поды
```
$ kubectl apply -f ./bad-pods/pods
```

```
pod/nothing-allowed-exec-pod unchanged
Error from server ([denied by psp-host-namespace] Sharing the host namespace is not allowed: everything-allowed-exec-pod
[denied by psp-host-network-ports] The specified hostNetwork and hostPort are not allowed, pod: everything-allowed-exec-pod. Allowed values: {"hostNetwork": false}
[denied by psp-privileged-container] Privileged container is not allowed: everything-allowed-pod, securityContext: {"privileged": true}
[denied by psp-host-filesystem] HostPath volume {"hostPath": {"path": "/", "type": ""}, "name": "noderoot"} is not allowed, pod: everything-allowed-exec-pod. Allowed path: [{"pathPrefix": "/foo", "readOnly": true}]): error when creating "../../kubernetes/bad-pods/everything-allowed-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-host-namespace] Sharing the host namespace is not allowed: everything-allowed-exec-pod
[denied by psp-host-network-ports] The specified hostNetwork and hostPort are not allowed, pod: everything-allowed-exec-pod. Allowed values: {"hostNetwork": false}
[denied by psp-privileged-container] Privileged container is not allowed: everything-allowed-pod, securityContext: {"privileged": true}
[denied by psp-host-filesystem] HostPath volume {"hostPath": {"path": "/", "type": ""}, "name": "noderoot"} is not allowed, pod: everything-allowed-exec-pod. Allowed path: [{"pathPrefix": "/foo", "readOnly": true}]
Error from server ([denied by psp-host-namespace] Sharing the host namespace is not allowed: hostipc-exec-pod): error when creating "../../kubernetes/bad-pods/hostipc-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-host-namespace] Sharing the host namespace is not allowed: hostipc-exec-pod
Error from server ([denied by psp-host-network-ports] The specified hostNetwork and hostPort are not allowed, pod: hostnetwork-exec-pod. Allowed values: {"hostNetwork": false}): error when creating "../../kubernetes/bad-pods/hostnetwork-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-host-network-ports] The specified hostNetwork and hostPort are not allowed, pod: hostnetwork-exec-pod. Allowed values: {"hostNetwork": false}
Error from server ([denied by psp-host-filesystem] HostPath volume {"hostPath": {"path": "/", "type": ""}, "name": "noderoot"} is not allowed, pod: hostpath-exec-pod. Allowed path: [{"pathPrefix": "/foo", "readOnly": true}]): error when creating "../../kubernetes/bad-pods/hostpath-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-host-filesystem] HostPath volume {"hostPath": {"path": "/", "type": ""}, "name": "noderoot"} is not allowed, pod: hostpath-exec-pod. Allowed path: [{"pathPrefix": "/foo", "readOnly": true}]
Error from server ([denied by psp-host-namespace] Sharing the host namespace is not allowed: hostpid-exec-pod): error when creating "../../kubernetes/bad-pods/hostpid-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-host-namespace] Sharing the host namespace is not allowed: hostpid-exec-pod
Error from server ([denied by psp-host-namespace] Sharing the host namespace is not allowed: priv-and-hostpid-exec-pod
[denied by psp-privileged-container] Privileged container is not allowed: priv-and-hostpid-pod, securityContext: {"privileged": true}): error when creating "../../kubernetes/bad-pods/priv-and-hostpid-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-host-namespace] Sharing the host namespace is not allowed: priv-and-hostpid-exec-pod
[denied by psp-privileged-container] Privileged container is not allowed: priv-and-hostpid-pod, securityContext: {"privileged": true}
Error from server ([denied by psp-privileged-container] Privileged container is not allowed: priv-pod, securityContext: {"privileged": true}): error when creating "../../kubernetes/bad-pods/priv-exec-pod.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by psp-privileged-container] Privileged container is not allowed: priv-pod, securityContext: {"privileged": true}

```

Попробуем создать еще деплойменты чтобы убедится что все работает идентично

```
kubectl apply -f ./bad-pods/deployments/

nrkk-osx:staging nrkk$ kubectl get deploy
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
everything-allowed-exec-deployment   0/2     0            0           21s
hostipc-exec-deployment              0/2     0            0           20s
hostnetwork-exec-deployment          0/2     0            0           20s
hostpath-exec-deployment             0/2     0            0           20s
hostpid-exec-deployment              0/2     0            0           20s
nothing-allowed-exec-deployment      2/2     2            2           20s
priv-and-hostpid-exec-deployment     0/2     0            0           20s
priv-exec-deployment                 0/2     0            0           20s

```
Удалим Gatekeeper

```
helm delete gatekeeper  --namespace gatekeeper 
```

## Завершение

Нам очень интересно ваше мнение про политики в k8s! [Ответьте, пожалуйста, на 3 вопроса тут](https://forms.yandex.ru/surveys/10027668.e6a191377042f39a03227983e4b6a247b0df8421/)


Для завершение стенда перейдите в раздел ../end

```
cd ../end
```

И далее в раздел [Удаление стенда](../end)