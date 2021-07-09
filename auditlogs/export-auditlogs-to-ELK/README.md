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
