FROM ghcr.io/codechips/vastai-base:latest

# Install nginx, Python dependencies, and memory optimization
RUN apt-get update && \
    apt-get install -y \
    nginx \
    apache2-utils \
    python3.10 \
    python3-pip \
    python3.10-venv \
    libgl1 \
    libglib2.0-0 \
    libtcmalloc-minimal4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create workspace directory and set ownership
RUN mkdir -p /opt/workspace && \
    chown -R appuser:appuser /opt/workspace

# Switch to non-root user for installation
USER appuser
WORKDIR /opt/workspace

# Clone Forge with version control
ARG FORGE_REF=main
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git stable-diffusion-webui-forge && \
    cd stable-diffusion-webui-forge && \
    git checkout "${FORGE_REF}"

# Create virtual environment and install dependencies with version protection
WORKDIR /opt/workspace/stable-diffusion-webui-forge
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip wheel setuptools && \
    # Install PyTorch with version tracking
    if [ "$(uname -m)" = "x86_64" ]; then \
        pip install torch==2.1.0+cu121 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121; \
    else \
        pip install torch==2.0.1 torchvision torchaudio; \
    fi && \
    torch_version=$(python -c 'import torch; print(torch.__version__)') && \
    # Install additional ML packages (skip xformers on ARM64)
    if [ "$(uname -m)" = "x86_64" ]; then \
        pip install xformers torch==${torch_version} --index-url https://download.pytorch.org/whl/cu121; \
        pip install onnxruntime-gpu; \
    fi && \
    pip install insightface transformers accelerate safetensors opencv-python-headless && \
    # Install Forge requirements (use requirements_versions.txt if available)
    if [ -f requirements_versions.txt ]; then \
        pip install -r requirements_versions.txt; \
    elif [ -f requirements.txt ]; then \
        pip install -r requirements.txt; \
    fi && \
    # Verify PyTorch version unchanged
    torch_version_post=$(python -c 'import torch; print(torch.__version__)') && \
    [ "$torch_version" = "$torch_version_post" ] || exit 1

# Test startup in CPU mode to verify installation
RUN . venv/bin/activate && \
    LD_PRELOAD=libtcmalloc_minimal.so.4 python launch.py \
        --use-cpu all \
        --skip-torch-cuda-test \
        --skip-python-version-check \
        --no-download-sd-model \
        --do-not-download-clip \
        --no-half \
        --port 11404 \
        --exit

# Switch back to root for system-level operations
USER root

# Copy configuration files
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/forge.conf /etc/nginx/sites-available/
COPY config/supervisord/*.conf /etc/supervisor/conf.d/
COPY scripts/setup-auth.sh /usr/local/bin/
COPY scripts/start-services.sh /usr/local/bin/
COPY scripts/entrypoint.sh /usr/local/bin/
COPY scripts/start-forge.sh /usr/local/bin/
COPY scripts/sync-workspace.sh /usr/local/bin/
COPY scripts/onstart.sh /root/

# Enable nginx site
RUN ln -s /etc/nginx/sites-available/forge.conf /etc/nginx/sites-enabled/ && \
    rm -f /etc/nginx/sites-enabled/default

# Make scripts executable
RUN chmod +x /usr/local/bin/setup-auth.sh /usr/local/bin/start-services.sh /usr/local/bin/entrypoint.sh /usr/local/bin/start-forge.sh /usr/local/bin/sync-workspace.sh /root/onstart.sh

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx /var/lib/nginx /var/cache/nginx /etc/nginx/conf.d /workspace && \
    chown -R appuser:appuser /var/log/nginx /var/lib/nginx /var/cache/nginx /opt/workspace && \
    touch /etc/nginx/.htpasswd && \
    chown appuser:appuser /etc/nginx/.htpasswd

# Set build arguments for credentials (can be overridden at build time)
ARG DEFAULT_USERNAME=admin
ARG DEFAULT_PASSWORD=admin

# Set environment variables
ENV USERNAME=${DEFAULT_USERNAME}
ENV PASSWORD=${DEFAULT_PASSWORD}
ENV OPEN_BUTTON_PORT=8000
ENV WORKSPACE=/workspace
ENV FORGE_ARGS=""

# Expose Forge UI port
EXPOSE 8000

# Set working directory
WORKDIR /workspace

# Support for different Vast.ai launch modes:
# - Entrypoint mode: Uses the ENTRYPOINT directive below
# - SSH/Jupyter mode: Ignores ENTRYPOINT, runs /root/onstart.sh instead
# For local testing: docker run vastai-forge

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
