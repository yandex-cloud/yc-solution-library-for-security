# Тестирование AntiDDos системы с помощью Yandex Load Testing
Решение позволяет вам протестировать AntiDDos систему с помощью [Yandex Load Testing](https://cloud.yandex.ru/docs/load-testing/)

**!!Важно!!: Используйте данный инструмент только для тестирования собственной инфраструктуры. Использование инструмента для нагрузки не ваших ресурсов может являться нарушением законодательства РФ и привести к негативным последствиям**

---

1) Подготовьте тестовую ВМ/сервис. Например с помощью решения [Установка уязвимого веб приложения (dvwa)](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/vuln-mgmt/vulnerable-web-app-waf-test) либо любой другой веб сервис

2) Включите защиту от L7 DDos/Dos в Yandex Cloud с помощью сервиса ["Yandex DDoS Protection: Расширенная защита"](https://cloud.yandex.ru/docs/vpc/ddos-protection/#advanced-protection) либо включите защиту от внешнего провайдера
---
(Расширенная защита работает на 3 и 7 уровнях модели OSI. Помимо этого вы сможете отслеживать показатели нагрузки, параметры атак и подключить Solidwall WAF в личном кабинете Qrator Labs. Чтобы включить расширенную защиту, обратитесь к вашему менеджеру или в техническую поддержку). Дополнительно можно подключить услугу WAF (Web Application Firewall)

3) Запросите у менеджера/архитектора/поддержки доступ к сервису [Yandex Load Testing](https://cloud.yandex.ru/docs/load-testing/)

4) Выполните первоначальную настрйоку сервиса, агента согласно инструкции [Как начать работать с Yandex Load Testing](https://cloud.yandex.ru/docs/load-testing/quickstart). 
--- 
Конфигурация агента выбирается исходя из желаемой нагрузки запросов в секунду (rps)
Все доступные конфигурации [представлены здесь](https://cloud.yandex.ru/docs/load-testing/concepts/agent) (10 000rps - small, 20 000 - medium 40 000 - large)

5) В меню сервиса нажмите **Создать тест** и выберите **Способ настройки** - Конфиг

6) Вставьте следующую конфигурацию (нагрузка в 4000 rps):
```Python
phantom:
  enabled: true
  package: yandextank.plugins.Phantom
  address: your-test-app:80
  ammo_type: uri
  load_profile:
    load_type: rps
    schedule: step(75, 4000, 25, 2m)
  ssl: false
  uris:
    - /
core: {}
cloudloader:
  enabled: true
  package: yandextank.plugins.CloudUploader
  job_name: omgplease.tk
  job_dsc: ''
  ver: '1'
  api_address: loadtesting.api.cloud.yandex.net:443
```
!Необходимо изменить порт 80 на 443 в случае использования https

![Screen Shot 2022-03-30 at 11 22 21](https://user-images.githubusercontent.com/85429798/160808020-2c9378f2-d5b6-40d0-abae-d6fab197b272.png)

7) Нажмите **Создать**

8) В результате запустится нагрузочный тест, отчет которого можно посмотреть провалившись в тест и выбрав кнопку **Отчет**

![Screen Shot 2022-03-30 at 11 24 52](https://user-images.githubusercontent.com/85429798/160808048-c5e0306e-01c9-47fc-b1da-f66c1dc3d33a.png)

9) В целевой системе защиты от DDos вы увидите оповещение об атаке типа **HTTP Misuse/Flood**.  Атака по протоколу HTTP. Направлена на перегрузку HTTP-сервиса большим количеством запросов.


