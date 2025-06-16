# ABOUTME: Base Dockerfile setup with CUDA, system packages, and user configuration
# ABOUTME: Foundation for a containerized environment with non-root user and workspace directory

FROM nvidia/cuda:12.2.0-cudnn8-runtime-ubuntu22.04

# Prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install essential packages
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim \
        git \
        python3 \
        supervisor && \
    # Clean up apt cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# Create a non-root user named appuser with UID 1000
RUN useradd -m -u 1000 appuser

# Create workspace directory
RUN mkdir -p /workspace

# Set ownership of workspace to appuser
RUN chown -R appuser:appuser /workspace

# Set working directory
WORKDIR /workspace