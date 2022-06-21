# Security in Gitlab instance check-list

- Общие рекомендации по безопасности. Пройдите по общему [чеклисту по безопасности от Gitlab](https://docs.gitlab.com/ee/security/). Там описаны ограничения: ssh ключей, webhooks, раннеров и др.
- Работа с Docker изнутри Gitlab:
    - не использовать shell executor/docker-in-docker(dind)/Docker socket binding, т.к. дает доступ к docker socket и priv mode. Подробности [в статье](https://blog.nestybox.com/2020/10/21/gitlab-dind.html). Безопасно использовать, например [kaniko](https://docs.gitlab.com/ee/ci/docker/using_kaniko.html)
    - придерживаться всех [лучших практик по безопасной работе с докер](https://docs.docker.com/engine/security/) образами без использования priveleged и ограниченные cap [согласно статье](https://docs.gitlab.com/runner/security/)
- Интеграция с Kubernetes:
    - не использовать deprecated способ интеграции gitlab с k8s [certificate-based](https://docs.gitlab.com/ee/user/infrastructure/clusters/) по причине использования sa с cluster-admin и необходимости открытия k8s-api во внешний  мир. Безопасным способом интеграции является [Gitlab Agent for Kubernetes](https://docs.gitlab.com/ee/user/clusters/agent/)
    - для деплоя в k8s использовать новый способ [ci/cd tunnel](https://docs.gitlab.com/ee/user/clusters/agent/ci_cd_tunnel.html), которые не требует связанности между ранером и k8s
- Использование env variables:
    - используйте [protected variables](https://docs.gitlab.com/ee/ci/variables/#protect-a-cicd-variable) для ограничения доступа и [mask variables](https://docs.gitlab.com/ee/ci/variables/#mask-a-cicd-variable) для маскирования в логах
    - не используйте секреты в коде, а также используйте инструмент [Secret Scanning](https://docs.gitlab.com/ee/user/application_security/secret_detection/) для поиска подобных ошибок
- Разграничение доступа:
    - выдавайте доступ в проект только необходимым людям и выдавайте им минимально необходимые права
    - используйте механизм [groups of projects](https://docs.gitlab.com/ee/user/group/)
    - включите ограничения подключений с конкретных ip адресов к gitlab instance на уровне gitlab. GroupName -> Settings – > General – > Permissions, LFS, 2FA
    - включите требование по 2FA. GroupName -> Settings – > General – > Permissions, LFS, 2FA
    - настройте [SAML SSO](https://docs.gitlab.com/ee/user/group/saml_sso/) с вашим корпоративным IDP для того. В противном случае придется управлять локальными пользователями со всеми минусами, локальными credentials и т.д.. 
    - по возможности отключите возможность fork. Project settings under general -> Visibility, project features, permissions.
- Безопасная конфигурация Gitlab instance:
    - старайтесь ограничить сетевой доступ Gitlab instance с внешним миром за пределами облака. [Инструкция:Ограничение сетевого доступа Managed Gitlab Instance с внешним миром](https://github.com/yandex-cloud/yc-solution-library-for-security/tree/master/secure_ci_cd/secure_ci_cd_with_webinar/gitlab_instance_sec_checklist/gitlab_instance_isolate.md)
    - используйте [User and IP rate limits](https://docs.gitlab.com/ee/user/admin_area/settings/user_and_ip_rate_limits.html) для предотвращения отказа в обслуживании
    
- Безопасная конфигурация runners:
    - не используйте shell executors, т.к. docker и k8s executors более изолированные и безопасные. [Сравнение](https://docs.gitlab.com/runner/executors/
)
    - ограничиваейте сетевой доступ runners с помощью [Yandex Cloud Security Groups](https://cloud.yandex.ru/docs/vpc/concepts/security-groups), чтобы они не имели бесконтрольного входящего и исходящего доступа
    - используйте механизм [назначения сервисных аккаунтов на VM](https://cloud.yandex.ru/docs/compute/operations/vm-connect/auth-inside-vm ) для взаимодействия с облачным API изнутри Jobs. Он более безопасен чем указание credentials через env
    - Используйте базовые рекомендации для ОС: Patching, vulnerability scanning, user isolation, transport security, secure boot, machine identity, etc. Например, NIST 800-53 
- Аудит и анализ событий безопасности: настройте [экспорт аудит логов](https://docs.gitlab.com/ee/administration/audit_event_streaming.html) в стороннюю систему для анализа событий (например [Yandex Managed Service for Elasticsearch в Yandex Cloud](https://cloud.yandex.ru/services/managed-elasticsearch)) либо Splunk
- Используйте [Signing Commit (gpg)](https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/) для подписи commits
- Используйте принцип как минимум 2-х персон, которые выполняют approve внесения изменений в код. [Merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
