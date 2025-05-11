#!/bin/sh
# Add the MinIO server alias
mc alias set miniosrv "$MINIO_SERVER_HOST" "$MINIO_SERVER_ACCESS_KEY" "$MINIO_SERVER_SECRET_KEY"

# Get source files list
echo "Getting source files from miniosrv/$1..."
SOURCE_FILES=$(mc ls "miniosrv/$1" | awk '{print $NF}')
SOURCE_COUNT=$(echo "$SOURCE_FILES" | wc -l)
echo "Waiting for $SOURCE_COUNT files in miniosrv/$2..."

# Wait loop
START_TIME=$(date +%s)
TIMEOUT=$3

while true; do
  # Check files
  TARGET_FILES=$(mc ls "miniosrv/$2" | awk '{print $NF}')
  MISSING_FILES=0
  for file in $SOURCE_FILES; do
    if ! echo "$TARGET_FILES" | grep -q "^$file$"; then
      MISSING_FILES=$((MISSING_FILES + 1))
    fi
  done
  
  [ "$MISSING_FILES" -eq 0 ] && break
  
  if [ $(($(date +%s) - START_TIME)) -gt $TIMEOUT ]; then
    echo "Timeout: Missing $MISSING_FILES files after $TIMEOUT seconds"
    exit 1
  fi
  
  sleep 30
  echo "Progress: $((SOURCE_COUNT - MISSING_FILES))/$SOURCE_COUNT files found..."
done

echo "All files verified"
exit 0