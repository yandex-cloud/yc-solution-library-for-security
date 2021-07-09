Заметки:

Конфиг filebeats для доставки json audittrail в ELK%


output.elasticsearch:
  hosts: ["c-c9qps9eabd0ok4haehjq.rw.mdb.yandexcloud.net:9200"]

  protocol: "https"
  ssl.certificate_authorities:
    - /var/log/root.crt
   Authentication credentials - either API key or username/password.
  #api_key: "id:api_key"
  username: "beats"
  password: "beats123"
  pipeline: replace_event_id


filebeat.inputs:

- type: log

   Change to true to enable this input configuration.
  enabled: true

   Paths that should be crawled and fetched. Glob based paths.
  paths:
    - /var/log/trail/*.json
    #- c:\programdata\elasticsearch\logs\*
  json.keys_under_root: true


---------

Создание индекса:
-сначала создать indexTemplate в web interface
-curl --user beats:beats123 -XPUT 'https://c-c9qps9eabd0ok4haehjq.rw.mdb.yandexcloud.net:9200/my-test-index' --cacert /var/log/root.crt


----------

Отправка событий через curl:

curl --user beats:beats123 --cacert /var/log/root.crt -v -XPOST "https://c-c9qps9eabd0ok4haehjq.rw.mdb.yandexcloud.net:9200/index-trail/doc1" -H 'Content-Type: application/json' -d @lane.json
[{"event_id":"aje08icd1utpv6sdut0s","event_source":"iam","event_type":"yandex.cloud.audit.iam.CreateAccessKey","event_time":"2021-06-23T15:56:06Z","authentication":{"authenticated":true,"subject_type":"FEDERATED_USER_ACCOUNT","subject_id":"ajesnkfkc77lbh50isvg","subject_name":"mirtov8@yandex-team.ru"},"authorization":{"authorized":true},"resource_metadata":{"path":[{"resource_type":"resource-manager.cloud","resource_id":"b1g3o4minpkuh10pd2rj","resource_name":"arch"},{"resource_type":"resource-manager.folder","resource_id":"b1gci8pu7s2seup3mpor","resource_name":"mirtov-terraform-play"}]},"request_metadata":{"remote_address":"cloud.yandex","user_agent":"Yandex Cloud","request_id":"145de09e-f419-41b4-9e05-ee6dd4e21d71"},"event_status":"DONE","details":{"access_key_id":"ajen8cbt6s3100qlq2eo","service_account_id":"ajebn2q9kbq1nnmtukjv","service_account_name":"sa-ta"}},
{"event_id":"ajehpht38uh1q0povo7j","event_source":"iam","event_type":"yandex.cloud.audit.iam.CreateApiKey","event_time":"2021-06-23T15:57:22Z","authentication":{"authenticated":true,"subject_type":"FEDERATED_USER_ACCOUNT","subject_id":"ajesnkfkc77lbh50isvg","subject_name":"mirtov8@yandex-team.ru"},"authorization":{"authorized":true},"resource_metadata":{"path":[{"resource_type":"resource-manager.cloud","resource_id":"b1g3o4minpkuh10pd2rj","resource_name":"arch"},{"resource_type":"resource-manager.folder","resource_id":"b1gci8pu7s2seup3mpor","resource_name":"mirtov-terraform-play"}]},"request_metadata":{"remote_address":"cloud.yandex","user_agent":"Yandex Cloud","request_id":"f66ff0de-53c1-4345-9c52-f3fd8dbdca04"},"event_status":"DONE","details":{"api_key_id":"aje9egud0e2a3206nv67","service_account_id":"ajebn2q9kbq1nnmtukjv","service_account_name":"sa-ta"}},
{"event_id":"ajelp2ual7c97ilksh3a","event_source":"iam","event_type":"yandex.cloud.audit.iam.CreateKey","event_time":"2021-06-23T15:57:29Z","authentication":{"authenticated":true,"subject_type":"FEDERATED_USER_ACCOUNT","subject_id":"ajesnkfkc77lbh50isvg","subject_name":"mirtov8@yandex-team.ru"},"authorization":{"authorized":true},"resource_metadata":{"path":[{"resource_type":"resource-manager.cloud","resource_id":"b1g3o4minpkuh10pd2rj","resource_name":"arch"},{"resource_type":"resource-manager.folder","resource_id":"b1gci8pu7s2seup3mpor","resource_name":"mirtov-terraform-play"}]},"request_metadata":{"remote_address":"cloud.yandex","user_agent":"Yandex Cloud","request_id":"892c12c6-ad02-426b-b375-38de7fdb6190"},"event_status":"DONE","details":{"key_id":"ajeq63no01b6p83mtt7s","service_account_id":"ajebn2q9kbq1nnmtukjv","service_account_name":"sa-ta"}}]

----------

