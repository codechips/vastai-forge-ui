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
    supervisor && \
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

# Create non-root user
RUN useradd -u 1000 -m appuser

# Create required directories
RUN mkdir -p /workspace /etc/supervisor/conf.d /var/log/supervisor /data

# Copy configuration files
COPY etc/supervisor/supervisord.conf /etc/supervisor/
COPY etc/supervisor/conf.d/*.conf /etc/supervisor/conf.d/
COPY usr/local/bin/entrypoint-filebrowser.sh /usr/local/bin/

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint-filebrowser.sh

# Set ownership
RUN chown -R appuser:appuser /workspace /data /var/log/supervisor

# Expose ports  
EXPOSE 7010 7020 8010

# Set working directory
WORKDIR /workspace

# Run supervisord as root (it will drop privileges for services as configured)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
