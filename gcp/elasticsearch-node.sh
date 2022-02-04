#!/bin/bash

FILE="/etc/opentargets.txt"
if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
        exit 0
fi

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
    -t buster-backports install default-jdk openjdk-11-jdk-headless net-tools wget uuid-runtime \
      python-pip python-dev libyaml-dev httpie jq gawk less silversearcher-ag apt-transport-https tmux zip unzip bzip2

# compute half memtotal gigs
mem_gb=$(awk '/MemFree/ { memv=$2/1024/1024; mem=(memv > 32)?32:memv; printf "%.0f\n", mem*0.8 }' /proc/meminfo)
# instance_name=$(http --ignore-stdin --check-status 'http://metadata.google.internal/computeMetadata/v1/instance/name'  "Metadata-Flavor:Google" -p b --pretty none)
cluster_id=$(uuidgen -r)

# ERROR: [2] bootstrap checks failed. You must address the points described in the following [2] lines before starting Elasticsearch.
#Jun  2 10:22:23 elasticsearch-genetics-node-21060210 systemd-entrypoint[24112]: bootstrap check failure [1] of [2]: memory locking requested for elasticsearch process but memory is not locked
#Jun  2 10:22:23 elasticsearch-genetics-node-21060210 systemd-entrypoint[24112]: bootstrap check failure [2] of [2]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured

elastic_version=7.15.1

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
apt-get install elasticsearch=$elastic_version kibana=$elastic_version

systemctl stop kibana
systemctl stop elasticsearch

cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: ${cluster_id}
network.host: 0.0.0.0
http.port: 9200
bootstrap.memory_lock: true
discovery.type: single-node
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

EOF

cat <<EOF > /etc/elasticsearch/jvm.options.d/10-mem.options
-Xms${mem_gb}g
-Xmx${mem_gb}g

EOF

# memory lock
echo "MAX_LOCKED_MEMORY=unlimited" >> /etc/default/elasticsearch
sed -i '46iLimitMEMLOCK=infinity' /usr/lib/systemd/system/elasticsearch.service


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
net.ipv4.tcp_tw_reuse = 1

EOF

# set all sysctl configurations
sysctl -p

# disable swap
swapoff -a

echo "block/sda/queue/scheduler = noop" >> /etc/sysfs.conf
#echo noop > /sys/block/sda/queue/scheduler

# sed -i 's/\#LimitMEMLOCK=infinity/LimitMEMLOCK=infinity/g' /usr/lib/systemd/system/elasticsearch.service

# systemctl daemon-reload
# echo install slasticsearch plugins gcs and gce


systemctl enable elasticsearch
systemctl start elasticsearch

cat <<EOF > /etc/kibana/kibana.yml
server.port: 5601
server.host: "localhost"
elasticsearch.hosts: ["http://127.0.0.1:9200"]

EOF

echo start kibana
systemctl enable kibana
systemctl start kibana

echo "already created" > $FILE
echo done.

