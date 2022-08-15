

# Установка решения с помощью Terraform




# Настройка Alerts и Destination
Алертинг и правила реагирования в Opensearch выполняется с помощью механизма Alerting https://opensearch.org/docs/latest/monitoring-plugins/alerting/index/

Наше решение уже загружает пример monitor, вы можете взять его как пример для старта. Перейдите во вкладку Alerting - Monitors и найдите там "test". Нажмите кнопку edit, промотайте вниз и раскройте вкладку triggers и в ней укажите action. Выберите там заранее созданный канал нотификации - https://opensearch.org/docs/latest/notifications-plugin/index/


# Установка Openasearch 
Для устновки opensearch можно воспользоваться оффициальной документацией. Например установка с помощью docker - https://opensearch.org/docs/2.1/opensearch/install/index/ 

Для настройки TLS в opensearch dashboard используйте инструкцию - https://opensearch.org/docs/2.1/dashboards/install/tls/

Для генерации самоподпсанного SSL сертификата используйте инстуркцию - https://opensearch.org/docs/2.1/security-plugin/configuration/generate-certificates/
Либо загружите ваш собственный сертификат

Здесь представлены мои тестовые примеры файлов для установки: ссылка на папку с docker compose и os dashboard

p.s: не забудьте предоставить необходимые права доступа на файлы с сертификатом и ключем