#!/bin/bash

# Vast.ai onstart script - executed automatically in SSH and Jupyter launch modes
# In SSH/Jupyter modes, Vast.ai overrides the Docker entrypoint with their own
# This script replaces the functionality of our Docker entrypoint
# Output is logged to /var/log/onstart.log

echo "Starting vastai-forge services..."
echo "Timestamp: $(date)"
echo "Launch mode: SSH/Jupyter (onstart.sh)"

# Run our entrypoint script which starts supervisord
# Run in background (&) to allow SSH to continue startup
/usr/local/bin/entrypoint.sh &

echo "Services started successfully"