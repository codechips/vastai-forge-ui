#!/bin/bash

# Entrypoint script for vastai-forge containers
# Extended version that includes forge-specific setup

set -euo pipefail

main() {
    echo "Starting vastai-forge container..."
    
    # Create necessary directories
    mkdir -p /var/log/supervisor
    mkdir -p /var/log/nginx
    mkdir -p /workspace
    
    # Set up authentication if credentials are provided
    setup_auth
    
    # Ensure proper ownership
    chown -R appuser:appuser /workspace /forge
    chown appuser:appuser /home/appuser
    
    # Set git safe directories to prevent ownership issues
    setup_git_config
    
    # Initialize forge if needed
    setup_forge
    
    # Start supervisord
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
}

setup_auth() {
    if [[ -n "${USERNAME:-}" && -n "${PASSWORD:-}" ]]; then
        echo "Setting up authentication..."
        /usr/local/bin/setup-auth.sh
    else
        echo "No credentials provided, skipping authentication setup"
    fi
}

setup_git_config() {
    echo "Setting up git configuration..."
    
    # Set git config for root
    git config --global --add safe.directory '*'
    git config --global user.email "root@vastai-forge"
    git config --global user.name "VastAI Forge"
    
    # Set git config for appuser
    sudo -u appuser bash -c "
        git config --global --add safe.directory '*'
        git config --global user.email 'appuser@vastai-forge'
        git config --global user.name 'VastAI Forge User'
    "
}

setup_forge() {
    echo "Setting up Forge environment..."
    
    # Ensure forge directory exists and is owned by appuser
    if [[ ! -d /forge ]]; then
        mkdir -p /forge
        chown appuser:appuser /forge
    fi
    
    # Ensure venv exists
    if [[ ! -d /forge/venv ]]; then
        echo "Creating Python virtual environment..."
        sudo -u appuser bash -c "cd /forge && python3 -m venv venv"
    fi
}

# Save environment variables to /etc/environment for persistence
save_environment() {
    echo "Saving environment variables..."
    {
        echo "# Vastai Forge environment variables"
        echo "PATH=\"$PATH\""
        echo "WORKSPACE=\"$WORKSPACE\""
        echo "USERNAME=\"${USERNAME:-admin}\""
        # Don't save PASSWORD for security
        echo "PYTHONPATH=\"/forge/venv/lib/python3.10/site-packages\""
    } > /etc/environment
}

# Trap signals and forward them to supervisord
trap 'echo "Received signal, shutting down..."; kill -TERM $supervisord_pid 2>/dev/null || true; wait $supervisord_pid 2>/dev/null || true' TERM INT

# Save environment before starting
save_environment

main "$@"