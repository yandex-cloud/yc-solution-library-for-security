FROM python:3.9.1-slim
RUN apt-get update
ADD /functions /functions
ADD /include /include
WORKDIR /
RUN mkdir /temp
RUN pip install --upgrade pip
RUN pip install -r /functions/requirements.txt
CMD ["python3", "functions/main.py"]