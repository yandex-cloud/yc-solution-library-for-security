# Обнаружение уязвимостей в CI/CD (Free лицензия)
Цель демонстрации - развертывание решения Kaspersky и удаленная установка агентов в Yandex.Cloud для обеспечения 

## Схема картинка

## Схема блок схема
#Short description of steps:
- Container scanning
    - build_docker_image 
    - container_scanning_free_trivy # for trivy scan or
    - container_scanning_free_yc # for yandex cloud container scanner 
- Push to prod registry
- SAST
- DAST
    - deploy (deploy app to staging k8s)
    - DAST scan
- Deploy to prod (only for merged: after approve of merge request)

## Инструкция как использовать