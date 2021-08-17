# Security-events-to-siem-importer

Описание: Модуль модуль который через очередь читает логи из бакета и кладет их Elastic


### Принимает на вход: 
	- folder_id 			- ID каталога 
	- log_bucket_name 		- имя S3 бакета, логи из которого нужно обрабатывать
	- service_account_id	- (опционально) ID сервисного аккаунта, который будет запускать фукнцию, создавать очереди и писать в очереди
	- auditlog_enabled 		- Включать ли поставку аулит лога (по умолчанию - true)
	- falco_enabled 		- Включать ли поставку аудит лога 
	- elastic_server      	- URL в виде "https://xxx.rw.mdb.yandexcloud.net"
	- elastic_user        	- Имя пользователя с административными правами в ElasticSearch
	- elastic_pw          	- Пароль пользователя ElasticSearch
	- coi_subnet_id       	- ID подсети, в которой будут созданы worker контейнеры для обработки данных


### Выполняет: 
	- Создание статического ключа для УЗ
	- Создание функций и тригеров для записи логов в очереди и обогащения логов параметрами 'cloud_id','folder_id','cluster_id','cluster_url'
	- Обработка логов из очереди через worker-контейнеры
	- Выгрузка логов в ElasticSearch
	

Пререквизиты:
1) Сервисная учетная запись с правами ymq.writer, serverless.functions.invoker, storage.editor 
2) ID подсети для создания контейнеров
3) Включенный NAT на выбранной подсети
3) Кластер ElasticSearch


### Вызов модуля
```

module "bucket_baby" {
    source = "../../../yc-solution-library-for-security/auditlogs/export-k8s-events-to-siem/security-events-to-siem-importer" # путь до модуля
    folder_id = "b1g1v8cu6isid0ms9va4" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id


    
    log_bucket_name = "logggs" //можно подставить из конфига развертывания
    service_account_id = "<>" //id выданный администратором

}



```

