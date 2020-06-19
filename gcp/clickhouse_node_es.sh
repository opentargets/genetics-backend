#!/bin/bash

#This script performs the following actions:
#  - Downloads, installs and configures Clickhouse and Elasticsearch
#  - Obtains scripts from `https://github.com/opentargets/genetics-backend/archive/${backend_version}.zip`
#  - Populates the Clickhouse DB using the SQL scripts in `./loaders/clickhouse/*.sql`
#  - Creates ES indices using `index_settings*.json` files in `./loaders/clickhouse/`

set -x
# See if the VM has already been configured
OT_RCFILE=/etc/opentargets.rc

if [ -f "$OT_RCFILE" ]; then
    echo "$OT_RCFILE exist so machine is already configured"
    exit 0
fi

## Versions
clickhouseVersion=20.4.5.36
elastic_version=7.x
backend_version=es7-test
genetics_data="gs://genetics-portal-output/20022712"

# Install dependencies
apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get \
    -o Dpkg::Options::="--force-confnew" \
    --force-yes \
    -fuy \
    dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get \
    -o Dpkg::Options::="--force-confnew" \
    --force-yes \
    -fuy \
    install default-jdk openjdk-11-jdk-headless bzip2 unzip zip wget net-tools wget uuid-runtime python-pip python-dev libyaml-dev httpie jq gawk tmux git build-essential less silversearcher-ag dirmngr psmisc

pip install elasticsearch-loader

# Install and configure Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/${elastic_version}/apt stable main" | \
    tee -a /etc/apt/sources.list.d/elastic-${elastic_version}.list

apt-get update && apt-get install elasticsearch kibana

systemctl stop kibana
systemctl stop elasticsearch

cluster_id=$(uuidgen -r)

cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: ${cluster_id}
node.name: 'genetics-es'
network.host: 0.0.0.0
http.port: 9200
bootstrap.memory_lock: true
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
discovery.type: single-node

EOF
mem=$(free -g  | grep Mem | awk '{print $2}')
es_mem=$((x/2 + 1))
# https://www.elastic.co/guide/en/elasticsearch/reference/master/jvm-options.html
cat <<EOF > /etc/elasticsearch/jvm.options.d/conf
-Xms${es_mem}g
-Xmx${es_mem}g
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-Des.networkaddress.cache.ttl=60
-Des.networkaddress.cache.negative.ttl=10
-XX:+AlwaysPreTouch
-Xss1m
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djna.nosys=true
-XX:-OmitStackTraceInFastThrow
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0
-Dio.netty.allocator.numDirectArenas=0
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true
-Djava.io.tmpdir=/tmp
-Djna.tmpdir=/tmp
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/var/lib/elasticsearch
-XX:ErrorFile=/var/log/elasticsearch/hs_err_pid%p.log

EOF

cat <<EOF > /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft memlock unlimited
* hard memlock unlimited
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited

EOF

cat <<EOF > /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
kernel.randomize_va_space = 1
fs.file-max = 65535
kernel.pid_max = 65536
net.ipv4.ip_local_port_range = 2000 65000
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_max_syn_backlog = 3240000
net.ipv4.tcp_fin_timeout = 15
net.core.somaxconn = 65535
net.ipv4.tcp_max_tw_buckets = 1440000
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = cubic
vm.swappiness = 1
vm.max_map_count=262144
net.ipv4.tcp_tw_reuse = 1

EOF

# set all sysctl configurations
sysctl -p

swapoff -a

echo "block/sda/queue/scheduler = noop" >> /etc/sysfs.conf

sed -i 's/\#LimitMEMLOCK=infinity/LimitMEMLOCK=infinity/g' /usr/lib/systemd/system/elasticsearch.service
sed -i '46iLimitMEMLOCK=infinity' /usr/lib/systemd/system/elasticsearch.service

systemctl daemon-reload

echo start elasticsearch
systemctl enable elasticsearch
systemctl start elasticsearch

## Configure and start kibana
cat <<EOF > /etc/kibana/kibana.yml
server.port: 5601
server.host: "localhost"

EOF

echo start kibana
systemctl enable kibana
sleep 3 && systemctl start kibana

# Install and configure clickhouse
echo install clickhouse
echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" > /etc/apt/sources.list.d/clickhouse.list


apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4
apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get \
    -o Dpkg::Options::="--force-confnew" \
    --force-yes \
    -fuy \
    dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get \
    -o Dpkg::Options::="--force-confnew" \
    --force-yes \
    -fuy \
    install clickhouse-client=$clickhouseVersion clickhouse-server=$clickhouseVersion

service clickhouse-server stop
/etc/init.d/clickhouse-server stop
killall clickhouse-server && sleep 5 

cat <<EOF > /etc/clickhouse-server/config.xml
<?xml version="1.0"?>
<yandex>
    <logger>
        <level>warning</level>
        <log>/var/log/clickhouse-server/clickhouse-server.log</log>
        <errorlog>/var/log/clickhouse-server/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>7</count>
    </logger>
    <display_name>ot-genetics</display_name>
    <http_port>8123</http_port>
    <tcp_port>9000</tcp_port>
    <interserver_http_port>9009</interserver_http_port>
    <listen_host>::</listen_host>
    <listen_host>0.0.0.0</listen_host>
    <listen_try>0</listen_try>
    <listen_reuse_port>1</listen_reuse_port>
    <listen_backlog>256</listen_backlog>
    <max_connections>2048</max_connections>
    <keep_alive_timeout>60</keep_alive_timeout>
    <max_concurrent_queries>256</max_concurrent_queries>
    <max_open_files>262144</max_open_files>
    <uncompressed_cache_size>17179869184</uncompressed_cache_size>
    <mark_cache_size>17179869184</mark_cache_size>
    <!-- Path to data directory, with trailing slash. -->
    <path>/var/lib/clickhouse/</path>
    <tmp_path>/var/lib/clickhouse/tmp/</tmp_path>
    <user_files_path>/var/lib/clickhouse/user_files/</user_files_path>
    <users_config>users.xml</users_config>
    <default_profile>default</default_profile>
    <!-- <system_profile>default</system_profile> -->
    <default_database>default</default_database>
    <umask>022</umask>
    <zookeeper incl="zookeeper-servers" optional="true" />
    <macros incl="macros" optional="true" />
    <dictionaries_config>*_dictionary.xml</dictionaries_config>
    <builtin_dictionaries_reload_interval>3600</builtin_dictionaries_reload_interval>
    <max_session_timeout>3600</max_session_timeout>
    <default_session_timeout>60</default_session_timeout>
    <distributed_ddl>
        <path>/clickhouse/task_queue/ddl</path>
    </distributed_ddl>
    <format_schema_path>/var/lib/clickhouse/format_schemas/</format_schema_path>
</yandex>
EOF

cat <<EOF > /etc/clickhouse-server/users.xml
<?xml version="1.0"?>
<yandex>
    <profiles>
        <default>
            <max_memory_usage>100000000000</max_memory_usage>
		    <max_bytes_before_external_sort>80000000000</max_bytes_before_external_sort>
		    <max_bytes_before_external_group_by>80000000000</max_bytes_before_external_group_by>
            <use_uncompressed_cache>1</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </default>
        <readonly>
            <max_memory_usage>100000000000</max_memory_usage>
		    <max_bytes_before_external_sort>80000000000</max_bytes_before_external_sort>
		    <max_bytes_before_external_group_by>80000000000</max_bytes_before_external_group_by>
            <use_uncompressed_cache>1</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
            <readonly>128</readonly>
        </readonly>
    </profiles>
    <users>
        <default>
            <password></password>
            <networks incl="networks" replace="replace">
                <ip>::/0</ip>
                <ip>0.0.0.0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
        </default>
        <readonly>
            <password></password>
            <networks incl="networks" replace="replace">
                <ip>::/0</ip>
                <ip>0.0.0.0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
        </readonly>
    </users>
    <quotas>
        <default>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </default>
    </quotas>
</yandex>
EOF

cat <<EOF > /etc/clickhouse-server/v2g_weights_dictionary.xml
<dictionaries>
	<dictionary>
        <name>v2gw</name>
        <source>
		    <file>
	            <path>/etc/clickhouse-server/dictionaries/v2g_scoring_source_weights.json</path>
	            <format>JSONEachRow</format>
		    </file>
        </source>
        <layout>
            <complex_key_hashed />
        </layout>
        <lifetime>600</lifetime>
        <structure>
            <key>
                <attribute>
                    <name>source_id</name>
                    <type>String</type>
                </attribute>
            </key>
            <attribute>
                <name>weight</name>
                <type>Float64</type>
                <null_value>0.0</null_value>
            </attribute>
        </structure>
	</dictionary>
</dictionaries>
EOF

mkdir /etc/clickhouse-server/dictionaries
echo copying dictionaries from gcloud to clickhouse dictionaries folder 
gsutil cp gs://genetics-portal-data/lut/v2g_scoring_source_weights.190521.json \
    /etc/clickhouse-server/dictionaries/v2g_scoring_source_weights.json

chown -R clickhouse:clickhouse /etc/clickhouse-server/dictionaries/

systemctl enable clickhouse-server
systemctl start clickhouse-server

echo "starting clickhouse... done."

echo "do not forget to create the tables and load the data in"
wget "https://github.com/opentargets/genetics-backend/archive/${backend_version}.zip"
unzip "${backend_version}.zip"
cd "genetics-backend-${backend_version}/loaders/clickhouse"
bash create_and_load_everything_from_scratch.sh ${genetics_data}

echo touching $OT_RCFILE
cat <<EOF > $OT_RCFILE
`date`
backend_version=${backend_version}
elastic_version=${elastic_version}
clickhouseVersion=${clickhouseVersion}
genetics_data=${genetics_data}
EOF
