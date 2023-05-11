# Custom policy for Kyverno

Набор Custom Policy 

- allow-actions-with-policys-only-silo-sa
Разрешает работу с ClusterPolicy только сервисному аккаунту управления ИБ

- deny-attach-by-pod-and-container
Блокирует attach к контейнеру (позволяет выполнять команды)

- mutate-securitycontext-seccomp
Принудительно добавляет в каждый deployment/pod RuntimeDefault профиль seccomp (защищает от множества уязв)

- restrict-image-registries
Разрешает загрузку образов только из "cr.yandex/*"

Будет пополняться