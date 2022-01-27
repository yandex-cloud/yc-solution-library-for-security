# Обнаружение уязвимостей в CI/CD (Ultimate лицензия)
Цель демонстрации - развертывание решения Kaspersky и удаленная установка агентов в Yandex.Cloud для обеспечения 

## Схема картинка

## Схема блок схема
#Short description of steps:
- Container scanning
    - build_docker_image 
    - container_scanning
    - cs-fail-on-detection (fail if you have critical vuln)
- Push to prod registry
- Dependency-checker
    - gemnasium-maven-dependency_scanning
    - dc-fail-on-detection (fail if you have critical vuln)
- SAST
- DAST
    - deploy (deploy app to staging k8s)
    - DAST scan
- Deploy to prod (only for merged: after approve of merge request)

## Инструкция как использовать