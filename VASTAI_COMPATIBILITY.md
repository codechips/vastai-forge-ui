# Vast.ai Compatibility Guide

This document explains how our Docker images work with Vast.ai's platform.

## Launch Modes

Our images support all three Vast.ai launch modes:

### 1. Entrypoint Mode
- Uses the Docker `ENTRYPOINT` directive
- Runs `/usr/local/bin/entrypoint.sh` directly
- Suitable for worker instances or API services

### 2. SSH Mode (Most Common)
- Vast.ai overrides the entrypoint with their own `/.launch` script
- Our `/root/onstart.sh` is automatically executed
- Services start via: `/.launch` → `/root/onstart.sh` → `/usr/local/bin/entrypoint.sh` → `supervisord`
- SSH access on port 22

### 3. Jupyter Mode
- Similar to SSH mode but with Jupyter on port 8080
- Also uses `/root/onstart.sh` for service startup

## Directory Structure

While Vast.ai recommends `/opt/workspace-internal/`, we use:
- `/forge` - Forge UI installation
- `/workspace` - User data and models
- `/forge/venv` - Python virtual environment

This approach:
- Keeps the application separate from user data
- Works both locally and on Vast.ai
- Maintains clean separation of concerns

## Environment Variables

Set these when creating instances:
- `USERNAME` - Basic auth username (default: admin)
- `PASSWORD` - Basic auth password (default: admin)

These are saved to `/etc/environment` for persistence across restarts.

## Security

Our approach:
- Basic authentication via nginx and htpasswd
- Services run as appropriate users (root for system services, appuser for Forge)
- Virtual environment isolates Python dependencies

For production use with Vast.ai's Caddy proxy, you could:
1. Disable our nginx proxy
2. Configure PORTAL_CONFIG for Vast.ai's security layer
3. Use their built-in TLS and auth tokens

## Service Management

All services are managed by supervisord:
- **Base image**: filebrowser, ttyd, logdy
- **Forge image**: Above plus nginx, forge UI

Check service status:
```bash
supervisorctl status
```

View logs:
```bash
tail -f /var/log/supervisor/*.log
tail -f /var/log/onstart.log  # Startup logs
```

## Testing Locally

```bash
# Build
docker build -t vastai-forge ./forge

# Run (mimics entrypoint mode)
docker run -it --rm -p 8000:8000 \
  -e USERNAME=admin \
  -e PASSWORD=test123 \
  vastai-forge

# Run (mimics SSH mode)
docker run -it --rm -p 8000:8000 \
  -e USERNAME=admin \
  -e PASSWORD=test123 \
  --entrypoint /bin/bash \
  vastai-forge -c "/root/onstart.sh && sleep infinity"
```

## Differences from Vast.ai Base Images

1. **Base Image**: We use `nvidia/cuda` instead of `vastai/base-image`
   - Pro: More control, works everywhere
   - Con: Missing Vast.ai's built-in portal and security features

2. **Virtual Environment**: `/forge/venv` instead of `/venv/main`
   - Isolated from system Python
   - Specific to Forge requirements

3. **Web Stack**: nginx instead of Caddy
   - Simpler for our use case
   - Could be replaced with Caddy if needed

## Best Practices

1. Always test in SSH mode as that's most common on Vast.ai
2. Check `/var/log/onstart.log` for startup issues
3. Use environment variables for configuration
4. Keep user data in `/workspace` for persistence
5. Monitor services with `supervisorctl status`