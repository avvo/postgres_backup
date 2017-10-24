# Postgres Backup
Backup postgres database to S3

# Environment Variables
Use these variables to configure your backups
* `AWS_ACCESS_KEY` AWS access key with access to your S3 bucket
* `AWS_SECRET_KEY` AWS secret key with access to your S3 bucket
* `S3_BUCKET` The bucket to upload your backups to
* `S3_PREFIX` The folder inside your S3 bucket to upload your backups to
* `POSTGRES_HOST` The postgresql host
* `POSTGRES_PORT` The postgresql port (default: 5432)
* `POSTGRES_USER` The postgresql user that has access to the databases you want to backup
* `POSTGRES_PASSWORD` The postgresql password
* `POSTGRES_DB` (optional, comma delimited) If defined the specific database(s) that should be backed up
