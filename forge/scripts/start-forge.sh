#!/bin/bash

# Startup script for Forge that ensures venv is properly activated

set -euo pipefail

echo "Starting Forge UI..."

# Git safe directory fix
export GIT_CONFIG_GLOBAL=/tmp/temporary-git-config
git config --file $GIT_CONFIG_GLOBAL --add safe.directory '*'

# Change to runtime directory
cd ${WORKSPACE}/stable-diffusion-webui-forge

# Activate virtual environment
source venv/bin/activate

# Ensure pip is up to date
pip install --upgrade pip

# Install/update requirements if they exist
if [ -f requirements.txt ]; then
    echo "Installing requirements..."
    pip install -r requirements.txt
fi

# Launch with memory optimization
echo "Launching Forge UI..."
exec LD_PRELOAD=libtcmalloc_minimal.so.4 python launch.py \
    --listen --port 8001 \
    --enable-insecure-extension-access \
    --no-half-vae \
    --opt-sdp-attention \
    ${FORGE_ARGS:-}