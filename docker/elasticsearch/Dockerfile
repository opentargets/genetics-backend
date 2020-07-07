# Elasticsearch 7.8.0

# This image re-bundles the Docker image from the upstream provider, Elastic.
FROM docker.elastic.co/elasticsearch/elasticsearch:7.8.0

# Set JVM options
COPY jvmOptions /etc/elasticsearch/jvm.options.d/conf

# Set security options
COPY limits.conf /etc/security/limits.conf

# Update sysctl
COPY sysctlES.conf /etc/sysctl.conf

# Set elastic options
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/
