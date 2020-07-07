FROM yandex/clickhouse-server

# Get dependencies
# RUN apt-get update \
#     && apt-get install --yes --no-install-recommends \
#     python \
#     python-pip \
#     python-setuptools

# RUN pip install --upgrade pip
# RUN pip install elasticsearch-loader

# Update env
ENV SCRIPT_DIR="/startup_scripts"
ENV DATA_VERSION="gs://genetics-portal-output/20022712"
# Configure clickhouse
COPY db_config/config.xml /etc/clickhouse-server/config.d/
COPY db_config/users.xml /etc/clickhouse-server/users.xml
RUN mkdir /etc/clickhouse-server/dictionaries
COPY --chown=clickhouse:clickhouse db_config/v2g_weights_dictionary.xml /etc/clickhouse-server/dictionaries
COPY db_config/v2g_scoring_source_weights.json /etc/clickhouse-server/dictionaries/v2g_scoring_source_weights.json

# # Initialisation statements for genetics DB
COPY db_initialisation /startup_scripts

COPY initialise.sh /docker-entrypoint-initdb.d/initialise.sh