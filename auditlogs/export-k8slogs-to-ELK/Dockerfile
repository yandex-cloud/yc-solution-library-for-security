FROM python:3.9.1-slim
RUN apt-get update
COPY /functions /functions
COPY /include /include
WORKDIR /
ENV ELASTIC_SERVER="https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net:9200"
ENV KIBANA_SERVER="https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net"
ENV ELASTIC_AUTH_USER="xxx"
ENV ELASTIC_AUTH_PW="xxx"
ENV S3_KEY="xxx"
ENV S3_SECRET="xxx"
ENV S3_BUCKET="xxx"
ENV SLEEP_TIME=60
RUN python3 -m pip install --upgrade pip
RUN pip install -r /functions/requirements.txt
CMD ["python3", "functions/main.py"]