FROM ghcr.io/codechips/vastai-base:latest

# Install nginx and Python dependencies
RUN apt-get update && \
    apt-get install -y \
        nginx \
        apache2-utils \
        python3.10 \
        python3-pip \
        python3.10-venv \
        libgl1 \
        libglib2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create forge directory and set ownership before switching user
RUN mkdir -p /forge && chown -R appuser:appuser /forge

# Switch to non-root user for pip installations
USER appuser
WORKDIR /forge

# Install PyTorch (will use CUDA on x86_64, CPU on ARM64)
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        pip3 install --user torch==2.1.0+cu121 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121; \
    else \
        pip3 install --user torch==2.0.1 torchvision torchaudio; \
    fi

# Clone Forge UI repository
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git .

# Create virtual environment and install dependencies
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip wheel setuptools

# Switch back to root for system-level operations
USER root

# Copy configuration files
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/forge.conf /etc/nginx/sites-available/
COPY config/supervisord/*.conf /etc/supervisor/conf.d/
COPY scripts/setup-auth.sh /usr/local/bin/
COPY scripts/start-services.sh /usr/local/bin/
COPY scripts/entrypoint.sh /usr/local/bin/

# Enable nginx site
RUN ln -s /etc/nginx/sites-available/forge.conf /etc/nginx/sites-enabled/ && \
    rm -f /etc/nginx/sites-enabled/default

# Make scripts executable
RUN chmod +x /usr/local/bin/setup-auth.sh /usr/local/bin/start-services.sh /usr/local/bin/entrypoint.sh

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx /var/lib/nginx /var/cache/nginx /etc/nginx/conf.d && \
    chown -R appuser:appuser /var/log/nginx /var/lib/nginx /var/cache/nginx /forge && \
    touch /etc/nginx/.htpasswd && \
    chown appuser:appuser /etc/nginx/.htpasswd

# Set build arguments for credentials (can be overridden at build time)
ARG DEFAULT_USERNAME=admin
ARG DEFAULT_PASSWORD=admin

# Set environment variables
ENV USERNAME=${DEFAULT_USERNAME}
ENV PASSWORD=${DEFAULT_PASSWORD}
ENV OPEN_BUTTON_PORT=8000

# Expose Forge UI port
EXPOSE 8000

# Set working directory
WORKDIR /forge

# Use our entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []