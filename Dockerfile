FROM nvidia/cuda:12.2.0-cudnn8-runtime-ubuntu22.04

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
RUN curl https://logdy.dev/install.sh | sh && \
    mv ~/.logdy/bin/logdy /usr/local/bin/logdy && \
    rm -rf ~/.logdy

# Install filebrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Create non-root user
RUN useradd -u 1000 -m appuser

# Create workspace directory
RUN mkdir -p /workspace && \
    chown appuser:appuser /workspace

# Set working directory
WORKDIR /workspace