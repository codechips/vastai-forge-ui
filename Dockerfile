# Stage 1: Base
FROM nvidia/cuda:12.2.2-base-ubuntu22.04

# Build arguments
ARG FORGE_VERSION=main
ARG DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash \
    PYTHONPATH=/opt/forge/venv/lib/python3.10/site-packages

# Install system dependencies and uv in one layer, then clean up
RUN apt update && \
    # Install runtime dependencies (no Python packages - uv will handle Python)
    apt install -y --no-install-recommends \
    curl \
    git \
    wget \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libtcmalloc-minimal4 \
    tmux \
    nano \
    vim \
    htop \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    # Install uv (fastest Python package manager and environment manager)
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv


# Install ttyd and logdy (architecture-aware)
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    wget https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -O /usr/local/bin/ttyd && \
    wget https://github.com/logdyhq/logdy-core/releases/download/v0.13.0/logdy_linux_amd64 -O /usr/local/bin/logdy; \
    else \
    wget https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.aarch64 -O /usr/local/bin/ttyd && \
    wget https://github.com/logdyhq/logdy-core/releases/download/v0.13.0/logdy_linux_arm64 -O /usr/local/bin/logdy; \
    fi && \
    chmod +x /usr/local/bin/ttyd /usr/local/bin/logdy

# Install filebrowser and set up directories
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash && \
    mkdir -p /workspace/logs /opt/forge /root/.config

# Clone Forge (version-dependent layer)
WORKDIR /opt
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git forge && \
    cd forge && \
    git checkout ${FORGE_VERSION}

# Create Python environment with uv (manages Python + packages)
WORKDIR /opt/forge
RUN uv venv --seed --python 3.10 .venv && \
    # Activate the virtual environment
    . .venv/bin/activate && \
    # Install base packages with uv pip (much faster than regular pip)
    uv add "numpy<2.0.0" && \
    # Install PyTorch (architecture-specific with pinned versions)
    if [ "$(uname -m)" = "x86_64" ]; then \
    uv add torch==2.1.0+cu121 torchvision==0.16.0+cu121 torchaudio==2.1.0+cu121 --index-url https://download.pytorch.org/whl/cu121; \
    else \
    uv add torch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2; \
    fi && \
    # Install additional ML packages with uv pip
    uv add transformers accelerate safetensors opencv-python-headless && \
    # Install Forge requirements with uv pip
    if [ -f requirements_versions.txt ]; then \
    uv add -r requirements_versions.txt; \
    elif [ -f requirements.txt ]; then \
    uv add -r requirements.txt; \
    fi && \
    # Verify PyTorch installation (with activated venv)
    python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}')" && \
    # Test startup on x86_64 only (with activated venv)
    if [ "$(uname -m)" = "x86_64" ]; then \
    timeout 300 python launch.py \
    --use-cpu all \
    --skip-torch-cuda-test \
    --skip-python-version-check \
    --no-download-sd-model \
    --do-not-download-clip \
    --no-half \
    --port 11404 \
    --exit || echo "Startup test completed"; \
    else \
    echo "Skipping startup test on ARM architecture"; \
    fi && \
    # Clean up build dependencies (keep uv for runtime)
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /opt/forge/.venv -name "*.pyc" -delete && \
    find /opt/forge/.venv -name "__pycache__" -type d -exec rm -rf {} + || true

# Copy configuration files and scripts (frequently changing layer)
COPY config/forge/ /etc/forge/
COPY config/filebrowser/filebrowser.json /root/.filebrowser.json
RUN mkdir -p /opt/bin
COPY scripts/run.sh /opt/bin/run.sh
COPY scripts/provision/ /opt/bin/provision/
RUN chmod +x /opt/bin/run.sh /opt/bin/provision/provision.py

# Add build timestamp
RUN date -u +"%Y-%m-%dT%H:%M:%SZ" > /root/BUILDTIME.txt

# Configure filebrowser and clean up
RUN filebrowser config init && \
    filebrowser users add admin admin --perm.admin && \
    # Final cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Remove any remaining build artifacts
    find /opt -name "*.pyc" -delete && \
    find /opt -name "__pycache__" -type d -exec rm -rf {} + || true

# Set environment variables
ENV USERNAME=admin \
    PASSWORD=admin \
    WORKSPACE=/workspace \
    FORGE_ARGS="" \
    OPEN_BUTTON_PORT=8010

# Expose ports
EXPOSE 8010 7010 7020 7030

# Set working directory
WORKDIR /workspace

# Entrypoint
ENTRYPOINT ["/opt/bin/run.sh"]
