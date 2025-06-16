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

# Create non-root user
RUN useradd -u 1000 -m appuser

# Create workspace directory
RUN mkdir -p /workspace && \
    chown appuser:appuser /workspace

# Set working directory
WORKDIR /workspace