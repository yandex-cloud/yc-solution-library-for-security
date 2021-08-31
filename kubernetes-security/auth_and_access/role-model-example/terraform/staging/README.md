# Настройка ролевого доступа - часть вторая, проверка доступов

Инициируем терраформ:
```
terraform init
```

Попробуем создать инфраструктуру от имени developer профиля:
```
YC_TOKEN=$(yc iam create-token --profile demo-developer-user1)
terraform apply
```
но у нас ничего не выйдет
```
Error: Error while requesting API to create network: server-request-id = f928c314-dc20-bd5a-8d4d-4f463c198582 server-trace-id = d7ab772355f5713e:d28b180b7261ff39:d7ab772355f5713e:1 client-request-id = 3cca1500-b5f6-4096-907a-2b3616ae889c client-trace-id = c6021829-467e-4eab-80f2-fe3db51e78a7 
rpc error: code = PermissionDenied desc = Permission denied
```

От имени devops пользователя все получится
```
YC_TOKEN=$(yc iam create-token --profile demo-devops-user1)
terraform apply
```
Тут надо подождать около 10 минут пока не создаться кластер



>Внимание! если вы используете security группы, то в целях демо разрешите в default sg доступ на 443 порт. Это можно сделать таким способом. Если у нас в облаке нет security групп, то ничего делать не нужно.

```
yc vpc security-group update-rules --id $(terraform output -json | jq -r .default_sg_id.value) --add-rule "direction=ingress,port=443,protocol=tcp,v4-cidrs=[0.0.0.0/0]" --profile=default
```

Попробуем зайти в кластер от имени develoer 
```
yc managed-kubernetes cluster get-credentials  --id $(terraform output   -json  | jq -r .cluster_id.value)  --context-name developer --external  --profile=demo-developer-user1 --force
```
И повыполняем разные команды
```
nrkk-osx:staging nrkk$ kubectl get nodes # не можем листить ноды
Error from server (Forbidden): nodes is forbidden: User "ajelrgfrac12re9quhkg" cannot list resource "nodes" in API group "" at the cluster scope
nrkk-osx:staging nrkk$ kubectl get clusterrolebindings #не можем листить clusterrolebinding
Error from server (Forbidden): clusterrolebindings.rbac.authorization.k8s.io is forbidden: User "ajelrgfrac12re9quhkg" cannot list resource "clusterrolebindings" in API group "rbac.authorization.k8s.io" at the cluster scope
nrkk-osx:staging nrkk$ kubectl get ns # можем листить ns
NAME              STATUS   AGE
default           Active   33m
kube-node-lease   Active   33m
kube-public       Active   33m
kube-system       Active   33m
test              Active   82s
nrkk-osx:staging nrkk$ kubectl create ns developer-1 # но не можем создавать
Error from server (Forbidden): namespaces is forbidden: User "ajelrgfrac12re9quhkg" cannot create resource "namespaces" in API group "" at the cluster scope
```
Переключимся на devops

```
yc managed-kubernetes cluster get-credentials  --id $(terraform output  -json | jq -r .cluster_id.value) --context-name devops --external --profile=demo-devops-user1 --force
```

Проверим доступы

```
$ kubectl get nodes # можем листить ноды
NAME                        STATUS   ROLES    AGE   VERSION
cl1eehipr45b2siq89pc-imyq   Ready    <none>   25m   v1.18.9
cl1eehipr45b2siq89pc-ubor   Ready    <none>   25m   v1.18.9
cl1eehipr45b2siq89pc-upox   Ready    <none>   25m   v1.18.9
nrkk-osx:staging nrkk$ kubectl create ns developer-1 #можем создавать ns
namespace/developer-1 created

```

Все получилось!

Переходим к следующему этапу - [настройка политик](../../kubernetes/)