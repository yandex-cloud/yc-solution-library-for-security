FROM python:3.9.1-slim
RUN apt-get update
# docker build нужно запускать из папки auditlogs чтобы был правильный контекст при подборе include файлов
# пример docker build команды: 
# docker build -t k8s-events-siem-worker:latest -f ./export-k8s-events-to-siem/security-events-to-siem-importer/worker/Dockerfile .
COPY /export-k8s-events-to-siem/security-events-to-siem-importer/worker/function /app/function
COPY /export-auditlogs-to-ELK/update-elk-scheme/include /app/include
WORKDIR /app
RUN python3 -m pip install --upgrade pip
RUN pip install -r /app/function/requirements.txt
CMD ["python3", "function/main.py"]