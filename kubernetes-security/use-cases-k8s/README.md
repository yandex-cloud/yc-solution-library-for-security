# Набор интересных событий безопасности в k8s audit logs

| | |
|-|-|
|Название|Запрос на языке ELK|
|Событие срабатывания Kyverno в режиме блокировки|filter "$.responseObject.status" = 'Failure' and $.responseObject.message" LIKE '%deny-exec-by-pod-and-container%'; (название политики меняем под свои политики)|
|События отказа в доступе - unauthorized|event.dataset : yandexcloud.k8s_audit_logs and responseStatus.reason : Forbidden and not user.name : (system*node* or *gatekeeper* or *kyverno* or *proxy* or *scheduler* or *anonymous* or *csi* or *controller*)|
|Назначение cluster-admin или admin роли (clusterrolebinding или rolebinding)|event.dataset : yandexcloud.k8s_audit_logs and requestObject.roleRef.name.keyword:(cluster-admin or admin) and objectRef.resource.keyword: (clusterrolebindings or rolebindings) and verb : create and not responseObject.reason : AlreadyExists|
|Успешное подключение к кластеру с внешнего IP адреса|event.dataset : yandexcloud.k8s_audit_logs and source.ip : * and not responseStatus.status : Failure|
|NetworkPolicies: создание, удаление, изменение (Cilium)|event.dataset : yandexcloud.k8s_audit_logs and requestObject.kind.keyword: (NetworkPolicy or CiliumNetworkPolicy or DeleteOptions) and verb : (create or update or delete) and objectRef.resource : networkpolicies|
|Exec внутрь контейнера (шелл внутрь контейнера)|event.dataset : yandexcloud.k8s_audit_logs and objectRef.subresource.keyword: exec|
|Добавить про /port-forward/proxy|event.dataset : yandexcloud.k8s_audit_logs and objectRef.subresource.keyword: portforward|
|Создание pod с image НЕ из Yandex container registry |event.dataset : yandexcloud.k8s_audit_logs and not requestObject.status.containerStatuses.image.keyword: *cr.yandex/* and requestObject.status.containerStatuses.containerID : *docker* and verb : patch and not  requestObject.status.containerStatuses.image.keyword: (*falco* or *openpolicyagent* or *kyverno* or *k8s.gcr.io*)|
|Создание pod в kube-system namespace|event.dataset : yandexcloud.k8s_audit_logs and objectRef.namespace.keyword: kube-system and verb : create and objectRef.resource.keyword: pods and objectRef.name : * and not objectRef.name : (*calico* or *dns* or *npd* or *proxy* or *metrics* or *csi* or *masq*)|
|Обращение к k8s-api под сервисным аккаунтом с внешнего ip адреса |event.dataset : yandexcloud.k8s_audit_logs and user.name : system\\\:serviceaccount\\\:* not source.ip: ("10.0.0.0/8 " or " 172.16.0.0/12" or " 192.168.0.0/16" |
|Falco удален|event.dataset : yandexcloud.k8s_audit_logs and verb : delete  and objectRef.namespace.keyword: falco and objectRef.resource.keyword : daemonsets|
|Удаление Kyverno из кластера k8s|event.dataset : yandexcloud.k8s_audit_logs and objectRef.name.keyword: kyverno-resource-validating-webhook-cfg and verb : delete|
|Изменение/удаление объекта Kyverno Policy|event.dataset : yandexcloud.k8s_audit_logs and objectRef.apiGroup.keyword: kyverno.io and (verb : delete or update) and objectRef.resource.keyword: *policies|
|Изменение /создание объекта external secrets учеткой отличной от ci/cd (данный объект ходит в lockbox и копирует оттуда секрет)|event.dataset : yandexcloud.k8s_audit_logs  and not user.name: "ajesnkfkc77lbh50isvg" and not user.name: "system:serviceaccount:external-secrets:external-secrets" and objectRef.name: "external-secret" and verb: (patch or create)|
|Чтение секретов под учетной записью пользователя (не под сервисным аккаунтом предназначеным для этого)|event.dataset : yandexcloud.k8s_audit_logs and objectRef.resource: "secrets" and verb: "get" and not user.name: ("system:serviceaccount:external-secrets:external-secrets" or "system:serviceaccount:kube-system:hubble-generate-certs" or "system:serviceaccount:kyverno:kyverno")|
|Создание сronjobs для persistence|filter objectRef.resource = "cronjobs" |
|Повышение привелегий sa|a) Checking to see if there are an unusually large number of "list" and "get" for Clusterroles, Roles, Rolebindings, Clusterrolebindings by a user.username  b) Checking if there are unusually large number of "forbids" for the user.username from associating a serviceaccount to one of these Rolebindings/Clusterrolebindings  c) Finally checking to see if there were "allows'' for the user.username to a Rolebinding/Clusterrolebinding.|
|Удаление events для затирания следов|filter verb = "delete", objectRef.resource = "events"|
