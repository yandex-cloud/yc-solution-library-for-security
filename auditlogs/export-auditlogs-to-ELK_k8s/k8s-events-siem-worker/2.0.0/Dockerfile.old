FROM python:3.9.10-slim
WORKDIR /app
COPY /function /app/function
COPY /include /app/include
RUN python3 -m pip install --upgrade pip && pip install -r /app/function/requirements.txt
CMD ["python3", "function/main.py"]
