for line in $(gsutil ls gs://genetics-portal-output/d2v2g/part-\*); do
	echo "loading file ${line}"
	gsutil cat $line | clickhouse-client -h 127.0.0.1 --query="insert into ot.d2v2g_log format JSONEachRow "
done

