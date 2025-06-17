#!/bin/bash

# Vast.ai onstart script - executed automatically by /.launch
# Output is logged to /var/log/onstart.log

echo "Starting vastai-forge services..."
echo "Timestamp: $(date)"

# Run our entrypoint script which starts supervisord
/usr/local/bin/entrypoint.sh &

echo "Services started successfully"