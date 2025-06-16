#!/bin/sh

# Set default values
USER="${USER:-admin}"
PASSWORD="${PASSWORD:-admin}"

# Set database path
DB_PATH="/data/filebrowser.db"

# Ensure data directory exists
mkdir -p /data

# Check if user exists
if filebrowser users ls --database "$DB_PATH" 2>/dev/null | grep -q "^$USER$"; then
    # User exists, update password
    filebrowser users update "$USER" --password "$PASSWORD" --database "$DB_PATH"
else
    # User doesn't exist, create with admin permissions
    filebrowser users add "$USER" "$PASSWORD" --perm.admin --database "$DB_PATH"
fi

# Launch filebrowser
exec filebrowser --database "$DB_PATH" --port 8080 --root /workspace