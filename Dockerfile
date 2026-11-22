FROM python:3.13-slim

WORKDIR /app
COPY app/requirements.txt .
RUN pip install -r requirements.txt 
COPY app/ .
RUN mkdir -p /data

EXPOSE 8000

CMD ["python", "-u", "app.py"]