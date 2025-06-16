# Vast.ai Forge UI Docker Images

Multi-stage Docker setup for running Stable Diffusion WebUI Forge on Vast.ai with integrated web-based management tools.

## Architecture

### Base Image (`ghcr.io/codechips/vastai-base`)
Foundation image with management tools:
- **Filebrowser** (port 7000): File management interface
- **ttyd** (port 7010): Web-based terminal
- **logdy** (port 7020): Log viewer
- **Supervisord**: Process management

### Forge Image (`ghcr.io/codechips/vastai-forge`)
Extends base image with:
- **Stable Diffusion WebUI Forge** (port 8000): AI image generation interface
- **Nginx reverse proxy**: Authentication for Forge UI
- **PyTorch 2.3.1 + CUDA 12.1**: Optimized for stability

## Quick Start

### For Vast.ai Users

1. Create a new instance with:
   ```
   Docker Image: ghcr.io/codechips/vastai-forge:latest
   ```

2. Configure environment variables:
   ```bash
   -e USERNAME=your_username -e PASSWORD=your_password -e OPEN_BUTTON_PORT=8000
   ```

3. Map ports:
   ```bash
   -p 8000:8000 -p 7000:7000 -p 7010:7010 -p 7020:7020
   ```

4. Launch with "Entrypoint" mode for best compatibility

### Access Your Services

- **Forge UI**: Port 8000 (main interface, protected with auth)
- **File Manager**: Port 7000 (manage models and outputs)
- **Terminal**: Port 7010 (command line access)
- **Logs**: Port 7020 (monitor all application logs including Forge UI)

## Default Credentials

- Username: `admin`
- Password: `admin`

## Directory Structure

```
vastai-forge-ui/
├── base/                    # Base image with management tools
│   ├── Dockerfile
│   ├── etc/supervisor/      # Process management configs
│   └── usr/local/bin/       # Scripts
├── forge/                   # Forge UI image
│   ├── Dockerfile
│   ├── config/              # Nginx and supervisord configs
│   └── scripts/             # Setup scripts
├── docs/                    # Documentation
└── .github/workflows/       # CI/CD pipeline
```

## Local Development

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Mise](https://mise.jdx.dev/) task runner

### Quick Start
```bash
# Build and test everything
mise run dev

# Or step by step:
mise run build    # Build both images
mise run test     # Start test container
mise run status   # Check service status
```

### Available Mise Tasks

#### Building
```bash
mise run build-base     # Build base image only
mise run build-forge    # Build forge image (depends on base)
mise run build          # Build both images
mise run build-no-cache # Build without cache (for debugging)
```

#### Testing
```bash
mise run test           # Start test container
mise run test-services  # Test services with curl
mise run dev            # Full development workflow
```

#### Management
```bash
mise run status         # Check container and service status
mise run logs           # Follow container logs
mise run shell          # Get shell access to container
mise run stop           # Stop test container
mise run clean          # Clean up everything
```

### Manual Docker Commands
If you prefer not to use Mise:
```bash
# Build images
cd base && docker build -t vastai-base:local .
cd ../forge && docker build -t vastai-forge:local .

# Run container
docker run -d --name vastai-test \
  -p 8000:8000 -p 7000:7000 -p 7010:7010 -p 7020:7020 \
  -e USERNAME=admin -e PASSWORD=admin \
  vastai-forge:local
```

## Log Monitoring

The logdy interface (port 7020) provides real-time monitoring of:

### Base Image Logs
- **Filebrowser**: Application logs and access logs
- **ttyd**: Terminal session logs
- **Supervisord**: Process management logs

### Forge Image Additional Logs
- **Forge UI**: Complete Stable Diffusion WebUI Forge logs including model loading, generation progress, and errors
- **Nginx**: Access and error logs for the authentication proxy
- **System**: All supervisord managed service logs

All logs are automatically rotated and easily searchable through the logdy web interface.

## Security Features

- Unified authentication across all services
- Basic authentication for Forge UI via nginx
- Native authentication for file browser and terminal
- Configurable credentials via environment variables

## Compatibility

- **CUDA**: 12.1 (with 12.2 base)
- **PyTorch**: 2.3.1 (recommended for stability)
- **Python**: 3.10
- **GPU**: NVIDIA GPUs with CUDA support
- **Platform**: Vast.ai, local Docker environments

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with both base and forge images
5. Submit a pull request

## License

This project is open source. Please check individual component licenses for specific terms.