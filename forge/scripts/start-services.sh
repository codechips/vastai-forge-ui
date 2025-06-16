#!/bin/bash

# Start services script
# This script ensures supervisord is running and starts it if needed

echo "Starting services..."

# Setup authentication first
/usr/local/bin/setup-auth.sh

# Check if supervisord is already running
if ! pgrep -f supervisord > /dev/null; then
    echo "Starting supervisord..."
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
    echo "Supervisord started"
else
    echo "Supervisord is already running"
fi

# Wait a moment for services to start
sleep 2

# Show status
echo "Service status:"
supervisorctl status

echo "Services started successfully!"
echo ""
echo "Available services:"
echo "- File Browser: http://localhost:7010"
echo "- Terminal (ttyd): http://localhost:7020" 
echo "- Log Viewer (logdy): http://localhost:7020"
echo "- Forge UI: http://localhost:8000"
echo ""
echo "Username: admin"
echo "Password: admin"