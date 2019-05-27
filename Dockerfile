FROM yandex/clickhouse-client:19.5.3.8

RUN apt-get update && apt-get install -y curl python python-pip && pip install elasticsearch-loader==0.2.25
COPY . ./genetics-backend
COPY ./clickhouse_client_settings.xml /etc/clickhouse-client/conf.d/

ENTRYPOINT [ "/bin/bash" ]
