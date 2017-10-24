#!/bin/bash

BACKUP_DIR=/backups
BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Exit if missing any required env variables
if [ -z "$AWS_ACCESS_KEY" ]; then
  echo 'Missing Environment Variable: AWS_ACCESS_KEY'
  exit
fi

if [ -z "$AWS_SECRET_KEY" ]; then
  echo 'Missing Environment Variable: AWS_SECRET_KEY'
  exit
fi

if [ -z "$S3_BUCKET" ]; then
  echo 'Missing Environment Variable: S3_BUCKET'
  exit
fi

if [ -z "$S3_PREFIX" ]; then
  echo 'Missing Environment Variable: S3_PREFIX'
  exit
fi

if [ -z "$POSTGRES_HOST" ]; then
  echo 'Missing Environment Variable: POSTGRES_HOST'
  exit
fi

if [ -z "$POSTGRES_USER" ]; then
  echo 'Missing Environment Variable: POSTGRES_USER'
  exit
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo 'Missing Environment Variable: POSTGRES_PASSWORD'
  exit
fi

backup_postgres() {
  mkdir -p $BACKUP_DIR
  export PGPASSWORD=$POSTGRES_PASSWORD
  PG_PARAMS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER"

  if [ -z "$DB_NAME" ]; then
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_DATE.psql"
    BACKUP_COMMAND="$PG_BACKUP $PG_PARAMS"
  else
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_DATE-$DB_NAME.psql"
    BACKUP_COMMAND="$PG_BACKUP $PG_PARAMS $DB_NAME"
  fi

  COMPRESSED_BACKUP_FILE="$BACKUP_FILE.gz"
  COMPRESSED_BACKUP_COMMAND="$BACKUP_COMMAND | gzip -9 > $COMPRESSED_BACKUP_FILE"
  # echo $COMPRESSED_BACKUP_COMMAND
  eval $COMPRESSED_BACKUP_COMMAND
}

upload_backups() {
  S3_CMD=$(which s3cmd)
  S3_PARAMS="--access_key $AWS_ACCESS_KEY --secret_key $AWS_SECRET_KEY"
  S3_UPLOAD_COMMAND="$S3_CMD $S3_PARAMS put --recursive $BACKUP_DIR/ s3://$S3_BUCKET/$S3_PREFIX/"
  # echo $S3_UPLOAD_COMMAND
  eval $S3_UPLOAD_COMMAND
}

if [ -z "$POSTGRES_DB" ]; then
  PG_BACKUP=$(which pg_dumpall)

  echo "Backing up all databases on $POSTGRES_HOST..."
  backup_postgres
else
  PG_BACKUP=$(which pg_dump)
  OLD_IFS=$IFS
  IFS=','
  
  for DB_NAME in $POSTGRES_DB; do
    echo "Backing up $DB_NAME on $POSTGRES_HOST..."
    backup_postgres
  done

  IFS=$OLD_IFS
fi

echo "Uploading backups to S3..."
upload_backups

# cleanup
rm -rf $BACKUP_DIR/*
echo "Backup complete!"
