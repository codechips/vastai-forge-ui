#!/bin/bash

# Setup authentication for all services
# This script runs before supervisord starts

# Set default values if not provided
USERNAME="${USERNAME:-admin}"
PASSWORD="${PASSWORD:-admin}"

echo "Setting up authentication for user: $USERNAME"

# Create htpasswd file for nginx basic auth
htpasswd -cb /etc/nginx/.htpasswd "$USERNAME" "$PASSWORD"

# Update ttyd command with credentials (substitute variables in supervisord config)
sed -i "s/\${USERNAME}/$USERNAME/g" /etc/supervisor/conf.d/ttyd.conf
sed -i "s/\${PASSWORD}/$PASSWORD/g" /etc/supervisor/conf.d/ttyd.conf

# Ensure proper ownership of log directories
chown -R appuser:appuser /var/log/supervisor

# Ensure workspace and data directories exist with proper permissions
mkdir -p /workspace /data
chown -R appuser:appuser /workspace /data

echo "Authentication setup completed"