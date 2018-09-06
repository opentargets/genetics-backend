for line in $(cat v2g_files.txt); do
	echo "loading file ${line}"
	gsutil cat $line | clickhouse-client -h 127.0.0.1 --query="insert into ot.v2g_log format JSONEachRow "
done

