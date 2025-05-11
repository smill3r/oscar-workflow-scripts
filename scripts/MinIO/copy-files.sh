#!/bin/sh
# Add the MinIO server alias
mc alias set miniosrv "$MINIO_SERVER_HOST" "$MINIO_SERVER_ACCESS_KEY" "$MINIO_SERVER_SECRET_KEY"

# Copy files between buckets
mc cp --recursive "miniosrv/$1" "miniosrv/$2"
echo "Copied $(mc ls "miniosrv/$1" | wc -l) files from $1 to $2"