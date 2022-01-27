# Ограничение сетевого доступа Managed Gitlab Instance с внешним миром

Сценарий в котором обращение к managed gitlab происходят только из сетей облака (доступ из интернета не используется)

## Инструкция
- смотрим приватный ip адрес gitlab instance через Облачные сети - подсеть - ip адреса - ресурс "label_resource-type-gitlab.instance"
- добавим новую [внутреннюю dns зону](https://cloud.yandex.ru/docs/dns/operations/zone-create-private) в cloud dns для gitlab.yandexcloud.net
- добавим [a запись](https://cloud.yandex.ru/docs/dns/operations/resource-record-create) для <имя вашего инстанса>.gitlab.yandexcloud.net.
- создадим новую ВМ для runner либо обновим кеш в текущей ВМ
- откроем сетевой доступ по 443 порту для ВМ в рамках VPC на дефолтной [Yandex Cloud Security Groups](https://cloud.yandex.ru/docs/vpc/concepts/security-groups) (на текущий момент на gitlab instance невозможно повесить отдельную SG, используется default SG)

## Результат
После чего при регистрации runners или доступа к UI возможно обращаться по имени gitlab, но резолв будет происходить по приватному ip адресу
