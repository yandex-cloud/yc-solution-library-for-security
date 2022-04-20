FROM python:3.9.10-slim
# docker build нужно запускать из папки auditlogs чтобы был правильный контекст при подборе include файлов
# пример docker build команды: 
# docker build -t k8s-events-siem-worker:latest -f ./export-auditlogs-to-ELK_k8s/k8s-events-siem-worker/2.0.0/Dockerfile .
WORKDIR /app
COPY /export-auditlogs-to-ELK_k8s/k8s-events-siem-worker/2.0.0/function /app/function
COPY /export-auditlogs-to-ELK_main/update-elk-scheme/include /app/include
RUN python3 -m pip install --upgrade pip && pip install -r /app/function/requirements.txt
CMD ["python3", "function/main.py"]