#!/usr/bin/env bash

# Simple process manager for Forge and Filebrowser
# Based on vastai-fooocus pattern

function start_filebrowser() {
    echo "filebrowser: starting"
    cd /root

    # Update password if provided
    if [[ ${PASSWORD} ]] && [[ ${PASSWORD} != "admin" ]]; then
        echo "filebrowser: updating admin password"
        /usr/local/bin/filebrowser users update admin -p ${PASSWORD}
    fi

    # Start filebrowser in background
    nohup /usr/local/bin/filebrowser >/workspace/logs/filebrowser.log 2>&1 &
    echo "filebrowser: started on port 7010"
    echo "filebrowser: log file at /workspace/logs/filebrowser.log"
}

function start_forge() {
    echo "forge: starting"
    cd /opt/forge

    # Activate the uv-created virtual environment
    source .venv/bin/activate

    # Default Forge arguments
    DEFAULT_ARGS="--listen --port 8010 --models-dir ${WORKSPACE}/models"

    # Add Gradio authentication using environment variables
    if [[ ${USERNAME} ]] && [[ ${PASSWORD} ]]; then
        AUTH_ARGS="--gradio-auth ${USERNAME}:${PASSWORD}"
        echo "forge: enabling Gradio authentication for user: ${USERNAME}"
    else
        AUTH_ARGS=""
        echo "forge: starting without authentication (no USERNAME/PASSWORD set)"
    fi

    # Combine default args with auth and any custom args
    FULL_ARGS="${DEFAULT_ARGS} ${AUTH_ARGS} ${FORGE_ARGS}"

    echo "forge: launching with args: ${FULL_ARGS}"
    nohup python launch.py ${FULL_ARGS} >/workspace/logs/forge.log 2>&1 &

    echo "forge: started on port 8010"
    echo "forge: log file at /workspace/logs/forge.log"
}

function start_ttyd() {
    echo "ttyd: starting web terminal"

    # Set up basic auth if password is provided
    if [[ ${PASSWORD} ]] && [[ ${PASSWORD} != "admin" ]]; then
        AUTH_ARGS="-c ${USERNAME}:${PASSWORD}"
    else
        AUTH_ARGS=""
    fi

    # Use -W flag to enable writable terminal (fixes readonly issue)
    nohup /usr/local/bin/ttyd ${AUTH_ARGS} -W -p 7020 bash >/workspace/logs/ttyd.log 2>&1 &
    echo "ttyd: started on port 7020 (writable mode)"
    echo "ttyd: log file at /workspace/logs/ttyd.log"
}

function start_logdy() {
    echo "logdy: starting log viewer"

    # Start logdy to follow all log files
    nohup /usr/local/bin/logdy follow /workspace/logs/*.log --port 7030 --ui-ip=0.0.0.0 --ui-pass=$PASSWORD --no-analytics >/workspace/logs/logdy.log 2>&1 &
    echo "logdy: started on port 7030"
    echo "logdy: log file at /workspace/logs/logdy.log"
}

function run_provisioning() {
    # Check if provisioning is enabled
    if [[ -z "${PROVISION_URL}" ]]; then
        echo "provisioning: PROVISION_URL not set, skipping model provisioning"
        return
    fi

    echo "provisioning: starting model provisioning"
    echo "provisioning: config URL: ${PROVISION_URL}"

    # Run provisioning script (uv will handle dependencies automatically)
    echo "provisioning: downloading models..."
    if /opt/bin/provision/provision.py "${PROVISION_URL}"; then
        echo "provisioning: completed successfully"
    else
        echo "provisioning: failed, but continuing startup"
        echo "provisioning: check /workspace/logs/provision.log for details"
    fi
}

function setup_workspace() {
    echo "Setting up workspace..."

    # Create log directory
    mkdir -p /workspace/logs

    # Create model directories if they don't exist
    mkdir -p /workspace/models/Stable-diffusion
    mkdir -p /workspace/models/VAE
    mkdir -p /workspace/models/Lora
    mkdir -p /workspace/models/embeddings
    mkdir -p /workspace/models/hypernetworks
    mkdir -p /workspace/models/ControlNet
    mkdir -p /workspace/models/ESRGAN
    mkdir -p /workspace/outputs

    # Link outputs directory only (models handled by --models-dir)
    cd /opt/forge
    if [ ! -L "outputs" ]; then
        rm -rf outputs 2>/dev/null || true
        ln -s /workspace/outputs outputs
        echo "Linked outputs to workspace"
    fi
}

function show_info() {
    echo ""
    echo "========================================="
    echo "VastAI Forge Container Started"
    echo "========================================="
    echo ""
    echo "Services:"
    echo "  - Forge WebUI: http://localhost:8010"
    echo "  - Filebrowser: http://localhost:7010"
    echo "  - Web Terminal: http://localhost:7020"
    echo "  - Log Viewer: http://localhost:7030"
    echo ""
    echo "Default credentials: ${USERNAME}/${PASSWORD}"
    echo ""
    echo "Logs:"
    echo "  - Forge: /workspace/logs/forge.log"
    echo "  - Filebrowser: /workspace/logs/filebrowser.log"
    echo "  - TTYd: /workspace/logs/ttyd.log"
    echo "  - Logdy: /workspace/logs/logdy.log"
    echo "  - Provisioning: /workspace/logs/provision.log"
    echo ""
    echo "Environment Variables:"
    echo "  - PROVISION_URL: ${PROVISION_URL:-not set}"
    echo "  - HF_TOKEN: ${HF_TOKEN:+present}"
    echo "  - CIVITAI_TOKEN: ${CIVITAI_TOKEN:+present}"
    echo ""
    echo "========================================="
}

# Main execution
echo "Starting VastAI Forge container..."

# Setup workspace
setup_workspace


# Start services
start_filebrowser
start_forge
start_ttyd
start_logdy

# Show information
show_info

# Run provisioning if enabled
run_provisioning

# Keep container running
echo ""
echo "Container is running. Press Ctrl+C to stop."
sleep infinity
