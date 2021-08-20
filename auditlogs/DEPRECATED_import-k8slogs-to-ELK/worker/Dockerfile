FROM python:3.9.1-slim
RUN apt-get update
COPY /function /app/function
COPY /include /app/include
WORKDIR /app
ENV ELASTIC_AUTH_PW="xxx"
ENV ELASTIC_AUTH_USER="xxx"
ENV ELASTIC_SERVER="xxx:9200"
ENV KIBANA_SERVER="xxx"
ENV S3_BUCKET="xxx"
ENV S3_KEY="xxx"
ENV S3_SECRET="xxx"
ENV SLEEP_TIME=60
ENV SQS_NAME="xxx" 
RUN python3 -m pip install --upgrade pip
RUN pip install -r /app/function/requirements.txt
CMD ["python3", "function/worker.py"]