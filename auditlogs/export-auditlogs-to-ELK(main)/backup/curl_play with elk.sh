Описание всего:>>>

Описание разовой загрузки объектов данных в ELK (bash скрипт либо питон) >>>

Создаем сам индекс
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X PUT "https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net:9200/audit-trails-index/?pretty" -H 'Content-Type: application/json' -d @/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/mapping6.json

загрузка  ingest pipeline curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X PUT "https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net:9200/_ingest/pipeline/audit-trails-pipeline?pretty" -H 'Content-Type: application/json' -d @/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/pipeline3.json

import kibana index pattern с нужным нашим id

curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/kibana_index_pattern.ndjson -H 'kbn-xsrf: true'

загрузка filters curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/filters.ndjson -H 'kbn-xsrf: true'

загрузка search curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/kibana_search2.ndjson -H 'kbn-xsrf: true'

загрузка dashboards curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/dashboard_very_new.ndjson -H 'kbn-xsrf: true'

Файл json необходимо преобразовать перед загрузкой в качестве bulk в elk

jq -c -r ".[]" /Users/mirtov8/Documents/CloudTrail/ArcSight\ Connector/gg/155732665.json | while read line; do echo '{"index":{}}'; echo $line; done > bulk.json

python пример ( пример - https://gist.github.com/icamys/4287ae49d20ff2add3db86e2b2053977#file-elastic_import_data_bulk-py-L51 )

Отправка bulk
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST "https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net:9200/audit-trails-index/_bulk?pipeline=audit-trails-pipeline" -H 'Content-Type: application/json' --data-binary "@./bulk3.json"

python пример ( https://elasticsearch-py.readthedocs.io/en/master/helpers.html ) (https://gist.github.com/icamys/4287ae49d20ff2add3db86e2b2053977#file-elastic_import_data_bulk-py-L51)

загрузка detections curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/detection_engine/rules/_import --form file=@./detections.ndjson -H 'kbn-xsrf: true'

______
k8s

curl --user beat:beat123 --cacert ~/.elasticsearch/root.crt -X GET "https://c-c9qps9eabd0ok4haehjq.rw.mdb.yandexcloud.net:9200/k8s-index?pretty"

curl --user beat:beat123 --cacert ~/.elasticsearch/root.crt -X PUT "https://c-c9qps9eabd0ok4haehjq.rw.mdb.yandexcloud.net:9200/k8s-index/?pretty" -H 'Content-Type: application/json' -d @//Users/mirtov8/Documents/GitHub/yc-solution-library-for-security/auditlogs/export-auditlogs-to-ELK/include/k8s/mapping_k8s.json
curl --user beat:beat123 --cacert ~/.elasticsearch/root.crt -X POST "https://c-c9qps9eabd0ok4haehjq.rw.mdb.yandexcloud.net:9200/k8s-index/_bulk?pipeline=k8s_audit-pipeline" -H 'Content-Type: application/json' --data-binary "@./bulk2.json"