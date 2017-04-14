#! /bin/sh

set -e

if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then
  echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
fi

if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then
  echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
fi

if [ "${S3_BUCKET}" == "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${S3_IAMROLE}" != "true" ]; then
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_REGION
fi

DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")

copy_s3 () {
  SRC_FILE=$1
  DEST_FILE=$2

  if [ "${S3_ENDPOINT}" == "**None**" ]; then
    AWS_ARGS=""
  else
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  echo "Uploading ${DEST_FILE} on S3..."
  
  aws configure set default.s3.multipart_threshold 128MB 
  cat $SRC_FILE | aws $AWS_ARGS s3 cp - s3://$S3_BUCKET/$S3_PREFIX/$DEST_FILE

  if [ $? != 0 ]; then
    >&2 echo "Error uploading ${DEST_FILE} on S3"
  fi

  rm $SRC_FILE
}

echo "Creating dump svn for ${BACKUP_DIR} ..."

DUMP_FILE="/tmp/backup.svn.dump"
TAR_GZ_FILE="/tmp/backup.svn.tar.gz"
svnadmin dump $BACKUP_DIR > $DUMP_FILE
tar czvf $TAR_GZ_FILE $DUMP_FILE

if [ $? == 0 ]; then
  S3_FILE="${DUMP_START_TIME}.backup.svn.tar.gz"

   copy_s3 $TAR_GZ_FILE $S3_FILE
else
  >&2 echo "Error creating dump of svn"
fi

rm $DUMP_FILE

echo "SVN backup finished"
