FROM yandex/clickhouse-client:19.5.3.8

RUN apt-get update && apt-get install -y curl python python-pip jq && pip install elasticsearch-loader==0.2.25
RUN curl https://sdk.cloud.google.com | bash && echo "source /root/google-cloud-sdk/completion.bash.inc; source /root/google-cloud-sdk/path.bash.inc" > /root/.bashrc
COPY . ./genetics-backend
# Fine-tuned clickhouse settings to enable loading of the data.
# These settings only apply for the client session and do not affect server settings for other connections (e.g. web application).
COPY ./clickhouse_client_settings.xml /etc/clickhouse-client/conf.d/

ENTRYPOINT [ "/bin/bash" ]
