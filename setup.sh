#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

export SMB_USER=${SMB_USER:-"u"}
SMB_PASSWORD=${SMB_PASSWORD:-"pw"}
SMB_GROUP=${SMB_GROUP:-$SMB_USER}
export READONLY=${READONLY:-"no"}

### Create samba user login if it does not exist.
if ! getent group $SMB_GROUP > /dev/null 2>&1; then
    groupadd -r $SMB_GROUP
fi
if ! id -u $SMB_USER > /dev/null 2>&1; then
    useradd -r -g $SMB_GROUP $SMB_USER
    (echo "$SMB_PASSWORD"; echo "$SMB_PASSWORD" ) | pdbedit -a -u "$SMB_USER"
fi

### Setup samba configuration file.
args=("$@")
echo "Setting up samba cfg ${args[@]}"
LIMIT=${#args[@]}
# last one is an empty string
# Running as an Entrypoint means the script is not arg0
for ((i=0; i < LIMIT ; i++)); do
    vol="${args[i]}"
    echo "add $vol"
    export VOLUME=$vol
    # Clean up $VOLUME to make $VOLUME_NAME
    export VOLUME_NAME=$(echo "$VOLUME" |sed "s/\///" |tr '[\/<>:"\\|?*+;,=]' '_')
    # Force samba to use user and group of the base directory
    export USER=$(ls -ld "$VOLUME" | awk '{print $3}')
    export GROUP=$(ls -ld "$VOLUME" | awk '{print $4}')
    # Assign a random group/user name to the group/user id if user does not exist.
    if ! getent group $GROUP > /dev/null 2>&1; then
        NEW_GROUP=$(cat /dev/urandom | tr -dc 'a-z' | head -c 10)
        groupadd -r --gid $GROUP $NEW_GROUP
        export GROUP=${NEW_GROUP}
    fi
    if ! id -u $USER > /dev/null 2>&1; then
        NEW_USER=$(cat /dev/urandom | tr -dc 'a-z' | head -c 10)
        useradd -r -u $USER -g $GROUP $NEW_USER
        export USER=${NEW_USER}
    fi
    cat /share.tmpl | envsubst >> /etc/samba/smb.conf
done

/etc/init.d/samba start
echo "watching /var/log/samba/*"
# Allow watching of logs via `docker log`, and blocks exit.
tail -f /var/log/samba/*
