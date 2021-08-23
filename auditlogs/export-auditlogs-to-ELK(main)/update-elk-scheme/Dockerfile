FROM python:3.9.1-slim
RUN apt-get update
COPY /function /app/function
COPY /include /app/include
WORKDIR /app
RUN python3 -m pip install --upgrade pip
RUN pip install -r /app/function/requirements.txt
CMD ["python3", "function/main.py"]