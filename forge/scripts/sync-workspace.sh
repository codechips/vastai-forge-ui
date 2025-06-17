#!/bin/bash
# Sync /opt/workspace to /workspace on first boot
# Based on Vast.ai's sync pattern

set -euo pipefail

sync_workspace() {
    local src="/opt/workspace"
    local dst="${WORKSPACE:-/workspace}"
    local lockfile="${dst}/.sync_forge_complete"
    
    # Skip if already synced
    if [[ -f "$lockfile" ]]; then
        echo "Workspace already synced, skipping..."
        return 0
    fi
    
    echo "Syncing workspace from $src to $dst..."
    
    # Create destination
    mkdir -p "$dst"
    
    # Copy forge installation
    if [[ -d "$src/stable-diffusion-webui-forge" && ! -d "$dst/stable-diffusion-webui-forge" ]]; then
        echo "Copying Forge installation..."
        cp -r "$src/stable-diffusion-webui-forge" "$dst/"
        
        # Set proper permissions
        chown -R appuser:appuser "$dst/stable-diffusion-webui-forge"
        
        # Mark as complete
        touch "$lockfile"
        echo "Workspace sync complete!"
    else
        echo "Forge already exists in workspace or source not found"
    fi
}

sync_workspace