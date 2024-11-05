FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .

RUN apt-get update && \
    apt-get install -y gcc libssl-dev libpq-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV DB_NAME=countdb
ENV DB_USER=mary
ENV DB_PASSWORD=123456A!
ENV DB_HOST=webcounter-db

EXPOSE 5000

CMD ["python", "app.py"]
