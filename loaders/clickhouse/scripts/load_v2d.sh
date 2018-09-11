for line in $(gsutil ls gs://genetics-portal-output/v2d/part-\*); do
	echo "loading file ${line}"
	gsutil cat $line | clickhouse-client -h 127.0.0.1 --query="insert into ot.v2d_log format JSONEachRow "
done
