#!/usr/bin/env bash

# Tool asumes sufficient compatibility of gsutil commmands with they unix counterparts.

if [ $# -lt 2 ]; then
    echo "Given a source path or uri (has to be the last argument) scripts detects the right tool to do the job (gsutil or unit tools) and runs it with all it's arguments."
    echo "Example of listing in Google Storage bucket: $0 ls -r gs://genetics-portal-sumstats/gwas/"
    echo "Example of listing in local file system: $0 ls -l /genetics-portal-sumstats/gwas/"
    exit 1
fi

CMD=$1
for LAST_ARG in $@; do :; done
if [ ${LAST_ARG:0:5} = gs:// ]; then
    gsutil "${CMD}" "${@:2}"
else
    "${CMD}" "${@:2}"
fi
