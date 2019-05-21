FROM yandex/clickhouse-client:19.5.3.8

RUN apt-get update && apt-get install -y python python-pip && pip install elasticsearch-loader==0.2.25
COPY . ./genetics-backend

ENTRYPOINT [ "/bin/bash" ]
