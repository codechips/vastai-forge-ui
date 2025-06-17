FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

# Prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install base packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    git \
    python3 \
    supervisor \
    sudo \
    apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ttyd
RUN wget https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 && \
    chmod +x ttyd.x86_64 && \
    mv ttyd.x86_64 /usr/local/bin/ttyd && \
    rm -f ttyd.x86_64

# Install logdy
RUN wget https://github.com/logdyhq/logdy-core/releases/download/v0.17.0/logdy_linux_amd64 -O /usr/local/bin/logdy && \
    chmod +x /usr/local/bin/logdy

# Install filebrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Create non-root user with proper shell setup
RUN useradd -u 1000 -m -s /bin/bash appuser && \
    echo 'export PATH="/home/appuser/.local/bin:$PATH"' >> /home/appuser/.bashrc && \
    echo 'cd /workspace' >> /home/appuser/.bashrc && \
    echo '# Auto-start services if not running' >> /home/appuser/.bashrc && \
    echo 'if command -v start-services.sh >/dev/null 2>&1 && ! pgrep -f supervisord >/dev/null; then' >> /home/appuser/.bashrc && \
    echo '    echo "Starting services..."' >> /home/appuser/.bashrc && \
    echo '    sudo /usr/local/bin/start-services.sh' >> /home/appuser/.bashrc && \
    echo 'fi' >> /home/appuser/.bashrc && \
    chown appuser:appuser /home/appuser/.bashrc && \
    echo 'appuser ALL=(ALL) NOPASSWD: /usr/local/bin/start-services.sh' >> /etc/sudoers

# Create required directories
RUN mkdir -p /workspace /etc/supervisor/conf.d /var/log/supervisor /data

# Copy configuration files
COPY etc/supervisor/supervisord.conf /etc/supervisor/
COPY etc/supervisor/conf.d/*.conf /etc/supervisor/conf.d/
COPY usr/local/bin/entrypoint-filebrowser.sh /usr/local/bin/
COPY scripts/entrypoint.sh /usr/local/bin/
COPY scripts/setup-auth.sh /usr/local/bin/
COPY scripts/onstart.sh /root/

# Make scripts executable
RUN chmod +x /usr/local/bin/entrypoint-filebrowser.sh /usr/local/bin/entrypoint.sh /usr/local/bin/setup-auth.sh /root/onstart.sh

# Set ownership
RUN chown -R appuser:appuser /workspace /data /var/log/supervisor

# Expose ports  
EXPOSE 7010 7020 8010

# Set working directory
WORKDIR /workspace

# Default CMD - supervisord will be started by onstart.sh when running on Vast.ai
# For local testing, you can override with: docker run --entrypoint /usr/local/bin/entrypoint.sh
CMD ["/bin/bash"]
