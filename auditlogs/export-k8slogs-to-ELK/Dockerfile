FROM python:3.9.1-slim
RUN apt-get update
COPY /functions /functions
COPY /include /include
WORKDIR /
ENV ELASTIC_SERVER="https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net:9200"
ENV KIBANA_SERVER="https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net"
ENV ELASTIC_AUTH_USER="admin"
ENV ELASTIC_AUTH_PW="elasticsearch123"
ENV S3_KEY="IyQPihPnSW6bL1wnVtZf"
ENV S3_SECRET="cX7JEHf-GrWJElzDm7KExzr2NXY-8SwiFwvGgko1"
ENV S3_BUCKET="k8s-ewjif"
ENV SLEEP_TIME=60
RUN python3 -m pip install --upgrade pip
RUN pip install -r /functions/requirements.txt
CMD ["python3", "functions/main.py"]