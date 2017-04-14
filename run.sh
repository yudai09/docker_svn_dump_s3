#! /bin/sh

set -e

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ "${SCHEDULE}" = "**None**" ]; then
  echo "run backup.sh" 
  sh backup.sh
else
  echo "go-cron backup.sh" 
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi
