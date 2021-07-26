FROM python:3.9.1
ENV ELASTIC_SERVER="https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net:9200"
ENV KIBANA_SERVER="https://c-c9q5sg9avnf2foe7gtqr.rw.mdb.yandexcloud.net"
ENV ELASTIC_CERT="include/ca.pem"
ENV ELASTIC_AUTH_USER="admin"
ENV ELASTIC_AUTH_PW="elasticsearch"
ENV ELASTIC_INDEX_NAME="audit-trails-index"
ENV S3_KEY="IyQPihPnSW6bL1wnVtZf"
ENV S3_SECRET="cX7JEHf-GrWJElzDm7KExzr2NXY-8SwiFwvGgko1"
ENV S3_BUCKET="audittrails"
ENV S3_FOLDER="logs"
ENV S3_LOCAL="./temp"
RUN apt-get update
ADD /functions /functions
ADD /include /include
WORKDIR /
RUN mkdir /temp
RUN pip install --upgrade pip
RUN pip install -r /functions/requirements.txt
CMD ["python3", "functions/main.py"]