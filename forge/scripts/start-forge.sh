#!/bin/bash

# Startup script for Forge that ensures venv is properly activated

set -euo pipefail

echo "Starting Forge UI..."

# Change to forge directory
cd /forge

# Activate virtual environment
source venv/bin/activate

# Ensure pip is up to date
pip install --upgrade pip

# Install/update requirements if requirements.txt exists
if [ -f requirements.txt ]; then
    echo "Installing requirements..."
    pip install -r requirements.txt
fi

# Launch Forge with the specified arguments
echo "Launching Forge UI..."
exec python launch.py --listen --port 8001 --enable-insecure-extension-access --no-half-vae --opt-sdp-attention