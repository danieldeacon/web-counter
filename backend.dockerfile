FROM python:3.8-slim

WORKDIR /app

COPY /web-counter/app.py \
     /web-counter/requirements.txt \
     /app/

RUN apt-get update && \
    apt-get install -y gcc libssl-dev libpq-dev && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir -r requirements.txt

ENV DB_NAME=countdb
ENV DB_USER=mary
ENV DB_PASSWORD=123456A!
ENV DB_HOST=webcounter-db

EXPOSE 5000

CMD ["python", "app.py"]