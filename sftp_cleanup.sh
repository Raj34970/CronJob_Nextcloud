#!/bin/bash

# loading the .env file
if [ ! -f "$(dirname "$0")/.env" ]; then RETURN_CODE=1; critical "No environment file, use the sample file"; fi
set -a
source "$(dirname "$0")/.env"
set +a

echo "=====Deleting the nextcloud old backups====="

for prefix in "nextcloud-config_" "nextcloud-data_" "nextcloud-db_"; do
    find "${SFTP_DIR}" -maxdepth 1 -name "${prefix}*" -printf '%T@ %p\0' \
        | sort -z -rn \
        | cut -z -d' ' -f2- \
        | tail -z -n +2 \
        | sudo xargs -0 --no-run-if-empty rm -rf --
done

echo "Disk space status for the SFTP server"
df -h ./ | cat