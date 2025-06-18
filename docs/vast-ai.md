# Vast.ai Docker Image Requirements and Considerations

This document contains important information extracted from Vast.ai documentation for building Docker images that will run on their platform.

## Template Configuration

### Docker Image Specification
- Use standard Docker pull syntax (e.g., `ubuntu:latest`)
- Supports custom Docker registry authentication
- Interface attempts to load version tags from Docker Hub

### Launch Modes
1. **SSH**: Direct remote access
2. **Jupyter**: Interactive notebook interface
3. **Entrypoint**: Standard Docker container execution

**Important**: SSH and Jupyter modes inject setup into your existing Docker image by replacing the entrypoint. This can cause compatibility issues with images using complex entrypoint scripts.

### Connection Methods
- **Proxy** (default): Works on machines without open ports
- **Direct**: Requires open ports, faster data transfer

## Docker Execution Environment

### Resource Allocation
- CPU, RAM, and shared memory are automatically assigned in proportion to your instance's cost vs the total machine cost
- Automatic resource constraints based on instance pricing

### Networking
- Full internet access
- Shared public IP addresses
- Port mapping is randomized
- Maximum of 64 total open ports per container
- Ports can be dynamically exposed using `-p` arguments

### Port Configuration
- SSH default port: 22
- Jupyter default port: 8080
- Custom ports can be mapped using `-p` syntax
- Example: `-p 5555:5555`

### Environment Variables

#### Predefined Variables
- `CONTAINER_API_KEY`: Per-instance API key
- `CONTAINER_ID`: Unique instance identifier
- `GPU_COUNT`: Number of GPU devices
- `PUBLIC_IPADDR`: Instance's public IP address
- `SSH_PUBLIC_KEY`: Account SSH public key
- `OPEN_BUTTON_PORT`: Port number that will be linked to the "Open" button in the Vast.ai interface. This allows you to specify which service should be easily accessible via the UI

#### Custom Variables
- Can be set using `-e` flag
- Example: `-e TZ=UTC`

### Storage
- Disk size set at instance creation (default 10GB)
- Cannot modify template on existing running instance
- Plan disk requirements carefully

### GPU Access
- Templates can be configured for specific GPU requirements
- GPU count available via `GPU_COUNT` environment variable
- Search interface helps find suitable GPU offers

## Best Practices for Vast.ai Docker Images

1. **Avoid Complex Entrypoints**: If using SSH or Jupyter launch modes, keep entrypoints simple as they will be replaced
2. **Port Mapping**: Be prepared to handle dynamic port assignments
3. **Disk Space**: Carefully estimate required disk space as it cannot be changed after instance creation
4. **Environment Variables**: Use the predefined variables to adapt your application to the Vast.ai environment
5. **Resource Awareness**: Your container will have resource limits based on instance pricing
6. **Network Security**: Remember that external ports are randomized for security

## Implications for Our Docker Images

Given these constraints, our Docker images should:
1. Use a simple CMD instead of complex ENTRYPOINT when possible
2. Be flexible with port assignments
3. Utilize environment variables for configuration
4. Ensure all services can work within resource constraints
5. Handle the SSH/Jupyter injection gracefully if those launch modes are used
6. Consider setting `OPEN_BUTTON_PORT` to point to our main service

## Our Docker Image Architecture

### Base Image: `ghcr.io/codechips/vastai-base`
**Ports (7xxx range):**
- **7010**: Filebrowser (file management with native auth)
- **7020**: ttyd (terminal access with credentials)
- **7030**: logdy (log viewer, read-only)

### Forge Image: `ghcr.io/codechips/vastai-forge`
**Inherits base services plus:**
- **8010**: Forge UI (protected with nginx basic auth) - `OPEN_BUTTON_PORT`

### Authentication
All services use unified credentials:
- Environment variables: `USERNAME` and `PASSWORD`
- Default: `admin` / `admin`

### Vast.ai Template Configuration
```
Docker Image: ghcr.io/codechips/vastai-forge:latest
Port Mappings: -p 8010:8010 -p 7010:7010 -p 7020:7020 -p 7030:7030
Environment: -e USERNAME=myuser -e PASSWORD=mypass -e OPEN_BUTTON_PORT=8010
Launch Mode: Entrypoint (recommended for multi-service setup)
```