# _Название
Описание всего:>>>


Описание разовой загрузки объектов данных в ELK (bash скрипт либо питон) >>>
1) Создаем сам индекс

curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X PUT "https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net:9200/audit-trails-index/?pretty" -H 'Content-Type: application/json' -d @/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/mapping6.json 

2) загрузка  ingest pipeline
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X PUT "https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net:9200/_ingest/pipeline/audit-trails-pipeline?pretty" -H 'Content-Type: application/json' -d @/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/pipeline3.json

3) import kibana index pattern с нужным нашим id

curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/kibana_index_pattern.ndjson -H 'kbn-xsrf: true'

4) загрузка filters
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/filters.ndjson -H 'kbn-xsrf: true'

5) загрузка search
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/kibana_search2.ndjson -H 'kbn-xsrf: true'


6) загрузка dashboards 
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/saved_objects/_import --form file=@/Users/mirtov8/Documents/CloudTrail/ELK-new-clean/dashboard_very_new.ndjson -H 'kbn-xsrf: true'

7) Файл json необходимо преобразовать перед загрузкой в качестве bulk в elk

jq -c -r ".[]" /Users/mirtov8/Documents/CloudTrail/ArcSight\ Connector/gg/155732665.json | while read line; do echo '{"index":{}}'; echo $line; done > bulk.json 

python пример ( пример - https://gist.github.com/icamys/4287ae49d20ff2add3db86e2b2053977#file-elastic_import_data_bulk-py-L51 )

8) Отправка bulk

curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt  -X POST "https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net:9200/audit-trails-index/_bulk?pipeline=audit-trails-pipeline" -H 'Content-Type: application/json' --data-binary "@./bulk3.json"

python пример ( https://elasticsearch-py.readthedocs.io/en/master/helpers.html ) (https://gist.github.com/icamys/4287ae49d20ff2add3db86e2b2053977#file-elastic_import_data_bulk-py-L51)

9) загрузка detections
curl --user beats:beats123 --cacert ~/.elasticsearch/root.crt -X POST https://c-c9qfr7e8e470ghr1lanf.rw.mdb.yandexcloud.net/api/detection_engine/rules/_import --form file=@./detections.ndjson -H 'kbn-xsrf: true'





Описание поставки данных из S3 нашим Python в Elastic >>>>





## Описание файлов:
- Папка object - содержит все объекты (dashboards, index_pattern, ingest_pipeline, searche_querys, detection_rules)
- ECS-mapping.docx - содержит описание мапинга полей json в Elastic Common Schema (ECS) (вставить ссылку)
- Описание объектов.docx - содержит подробное описание контента

## Dashboards:

![image](https://user-images.githubusercontent.com/85429798/125829594-3fab4999-e010-4bd8-86b0-20acdcfb69c9.png)

## Saved_querys:

![image](https://user-images.githubusercontent.com/85429798/125829729-15aae7f7-39b8-4aec-8286-357887c22532.png)

## Detection rules
описание

## ECS mapping:

![image](https://user-images.githubusercontent.com/85429798/125829841-2ba8b617-72fe-469f-afbb-23c123e6a4ba.png)
![image](https://user-images.githubusercontent.com/85429798/125829855-17e82a95-a9ca-4bc1-b0de-3303792caf25.png)

## Описание объектов:

![image](https://user-images.githubusercontent.com/85429798/125829924-c65013ca-c801-4de8-9aba-7b9da168dcec.png)
![image](https://user-images.githubusercontent.com/85429798/125829935-c71833c9-0013-4d52-9e66-b96cde65b9a5.png)
