FROM python:3.9.1-slim
RUN apt-get update
COPY /function /app
WORKDIR /app
ENV S3_BUCKET="xxx"
ENV S3_KEY="xxx"
ENV S3_SECRET="xxx"
ENV SLEEP_TIME=60
ENV SQS_NAME="xxx" 
RUN python3 -m pip install --upgrade pip
RUN pip install -r /app/requirements.txt
CMD ["python3", "pusher.py"]