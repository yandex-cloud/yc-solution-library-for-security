# Обнаружение уязвимостей в CI/CD (Free лицензия)

## Схема 
![image](https://user-images.githubusercontent.com/85429798/154644100-b091a363-7024-4ccf-8eb6-6dfbb385424f.png)


## Схема (из чего состоит pipeline)
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
Вы можете скачать данные файлы и использовать их в качестве security pipeline для вашего проекта. Подробности из вебинара размещены на корневой странице раздела. 
