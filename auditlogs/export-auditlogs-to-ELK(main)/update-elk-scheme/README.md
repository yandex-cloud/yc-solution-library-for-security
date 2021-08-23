Для обновления артефактов Kibana необходимо запустить контейнер, передав ему атрибутры для подключения к сервеу Kibana в параметрах окружения:

docker run -it --rm -e ELASTIC_AUTH_USER='admin' \
-e ELASTIC_AUTH_PW='password' \
-e KIBANA_SERVER='https://xxx.rw.mdb.yandexcloud.net' \
--name elk-updater cr.yandex/crpjfmfou6gflobbfvfv/elk-updater:latest

В результате выполнения будут обновлены следующие объекты Kibana:
- Dashboard
- Detection Rules
- Filters
- Index Patterns