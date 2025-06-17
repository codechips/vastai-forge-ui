# Vast.ai Forge UI Docker Image

Simplified single Docker image for running Stable Diffusion WebUI Forge on Vast.ai with integrated web-based management tools.

## Features

**All-in-one Docker image** with:
- **Stable Diffusion WebUI Forge** (port 8010): AI image generation interface
- **Filebrowser** (port 7010): File management interface
- **ttyd** (port 7020): Web-based terminal (writable)
- **logdy** (port 7030): Log viewer
- **PyTorch 2.1.0 + CUDA 12.1**: Optimized for stability
- **Simple process management**: No complex orchestration

## Quick Start

### For Vast.ai Users

1. Create a new instance with:
   ```
   Docker Image: ghcr.io/codechips/vastai-forge:latest
   ```

2. Configure environment variables:
   ```bash
   -e USERNAME=your_username -e PASSWORD=your_password -e OPEN_BUTTON_PORT=8010
   ```

3. Map ports:
   ```bash
   -p 8010:8010 -p 7010:7010 -p 7020:7020 -p 7030:7030
   ```

4. Launch with "Entrypoint" mode for best compatibility

### Access Your Services

- **Forge UI**: Port 8010 (main interface, protected with Gradio auth)
- **File Manager**: Port 7010 (manage models and outputs, protected with auth)
- **Terminal**: Port 7020 (command line access, writable, protected with auth)
- **Logs**: Port 7030 (monitor all application logs)

## Default Credentials

- Username: `admin`
- Password: `admin`

## Directory Structure

```
vastai-forge-ui/
├── Dockerfile               # Single image with all components
├── scripts/
│   └── run.sh              # Simple process manager
├── config/
│   ├── filebrowser/        # Filebrowser configuration
│   └── forge/              # Forge configuration (if any)
├── docs/                   # Documentation
└── .mise.toml              # Task runner configuration
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
mise run build    # Build image
mise run test     # Start test container
mise run status   # Check service status
```

### Available Mise Tasks

#### Building
```bash
mise run build          # Build image
mise run build-no-cache # Build without cache (for debugging)
mise run build-prod     # Build production image for linux/amd64
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
# Build image
docker build -t vastai-forge:local .

# Run container
docker run -d --name vastai-test \
  -p 8010:8010 -p 7010:7010 -p 7020:7020 -p 7030:7030 \
  -e USERNAME=admin -e PASSWORD=admin \
  vastai-forge:local
```

## Log Monitoring

The logdy interface (port 7030) provides real-time monitoring of:

- **Forge UI**: Complete Stable Diffusion WebUI Forge logs including model loading, generation progress, and errors
- **Filebrowser**: Application logs and access logs
- **ttyd**: Terminal session logs
- **Logdy**: Log viewer service logs

All logs are easily searchable through the logdy web interface.

## Security Features

- **Unified authentication** across all services:
  - Forge UI: Gradio built-in authentication
  - Filebrowser: Native authentication 
  - ttyd terminal: Basic authentication
- **Configurable credentials** via environment variables (USERNAME/PASSWORD)
- **Simple, secure access** to all management tools

## Compatibility

- **CUDA**: 12.1 (with 12.2 base)
- **PyTorch**: 2.1.0 (with CUDA 12.1 support)  
- **Python**: 3.10 (Ubuntu 22.04 default)
- **GPU**: NVIDIA GPUs with CUDA support
- **Platform**: Vast.ai, local Docker environments
- **Architecture**: x86_64 and ARM64

## Contributing

1. Fork the repository
2. Create a feature branch  
3. Make your changes
4. Test with `mise run dev`
5. Submit a pull request

## License

This project is open source. Please check individual component licenses for specific terms.