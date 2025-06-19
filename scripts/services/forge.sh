#!/usr/bin/env bash
# Forge WebUI service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

function start_forge() {
    echo "forge: starting"
    cd /opt/forge

    # Activate the uv-created virtual environment
    source .venv/bin/activate

    # Default Forge arguments
    DEFAULT_ARGS="--listen --port 8010 --models-dir ${WORKSPACE}/forge/models"

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

    # Prepare TCMalloc for better memory performance
    prepare_tcmalloc

    # Use accelerate by default, allow opt-out
    if [[ "${NO_ACCELERATE}" != "True" ]] && command -v accelerate >/dev/null 2>&1; then
        echo "forge: launching with accelerate and args: ${FULL_ARGS}"
        nohup accelerate launch --num_cpu_threads_per_process=6 launch.py ${FULL_ARGS} >/workspace/logs/forge.log 2>&1 &
    else
        echo "forge: launching with standard python and args: ${FULL_ARGS}"
        nohup python launch.py ${FULL_ARGS} >/workspace/logs/forge.log 2>&1 &
    fi

    echo "forge: started on port 8010"
    echo "forge: log file at /workspace/logs/forge.log"
}

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    start_forge
fi