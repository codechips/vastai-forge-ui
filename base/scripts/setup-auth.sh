#!/bin/bash

# Setup basic authentication for web services
# This script creates a password file for nginx basic auth

set -euo pipefail

setup_auth() {
    local username="${USERNAME:-admin}"
    local password="${PASSWORD:-admin}"
    
    echo "Setting up authentication for user: $username"
    
    # Create htpasswd file for nginx basic auth
    echo "$password" | htpasswd -c -i /etc/nginx/.htpasswd "$username"
    
    # Set proper permissions
    chmod 644 /etc/nginx/.htpasswd
    
    echo "Authentication setup complete"
}

# Install htpasswd if not available
if ! command -v htpasswd >/dev/null 2>&1; then
    echo "Installing apache2-utils for htpasswd..."
    apt-get update
    apt-get install -y apache2-utils
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi

# Create nginx directory if it doesn't exist
mkdir -p /etc/nginx

setup_auth