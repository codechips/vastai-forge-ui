# VastAI Forge Provisioning System

Fast, parallel model provisioning for HuggingFace, CivitAI, and direct URLs with token pre-validation and graceful error handling.

## Features

- **Multi-source support**: HuggingFace, CivitAI, and direct URLs (Google Drive, S3, etc.)
- **Parallel downloads**: Concurrent downloads for maximum speed
- **Token validation**: Pre-validates HF and CivitAI tokens before attempting downloads
- **Gated model handling**: Graceful fallback for inaccessible gated models
- **Progress tracking**: Real-time download progress and logging
- **Smart URL processing**: Automatic Google Drive link conversion
- **Authentication support**: Headers and tokens for private repositories

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PROVISION_URL` | URL to TOML configuration file | Yes (to enable provisioning) |
| `HF_TOKEN` | HuggingFace API token | No (for gated models) |
| `CIVITAI_TOKEN` | CivitAI API token | No (for some models) |

## Configuration Format

Create a TOML file with model definitions organized by category:

```toml
[models.checkpoints]
"model-name" = {
    source = "huggingface",
    repo = "user/repo-name",
    file = "model.safetensors",
    gated = true  # optional
}

[models.lora]
"lora-name" = {
    source = "civitai", 
    model_id = "123456",
    filename = "custom-name.safetensors"  # optional
}

[models.vae]
"vae-name" = {
    source = "url",
    url = "https://example.com/model.safetensors",
    headers = { "Authorization" = "Bearer token" }  # optional
}
```

## Supported Model Categories

- `checkpoints` → `/workspace/models/Stable-diffusion/`
- `lora` → `/workspace/models/Lora/`
- `vae` → `/workspace/models/VAE/`
- `controlnet` → `/workspace/models/ControlNet/`
- `esrgan` → `/workspace/models/ESRGAN/`
- `embeddings` → `/workspace/models/embeddings/`
- `hypernetworks` → `/workspace/models/hypernetworks/`

## Source Types

### HuggingFace

```toml
"model-name" = {
    source = "huggingface",
    repo = "stabilityai/stable-diffusion-xl-base-1.0",
    file = "sd_xl_base_1.0.safetensors",
    gated = true  # for gated models
}
```

### CivitAI

```toml
"model-name" = {
    source = "civitai",
    model_id = "130072",
    filename = "custom-name.safetensors"  # optional
}
```

### Direct URLs

```toml
# Simple URL
"model-name" = "https://example.com/model.safetensors"

# Advanced URL with options
"model-name" = {
    source = "url",
    url = "https://drive.google.com/file/d/1ABC123/view",
    filename = "model.safetensors",
    headers = { "User-Agent" = "MyApp/1.0" }
}
```

## Google Drive Support

Google Drive URLs are automatically converted to direct download links:

```toml
# These formats are all supported:
"gdrive-model-1" = "https://drive.google.com/file/d/1ABC123/view"
"gdrive-model-2" = "https://drive.google.com/uc?id=1ABC123"
"gdrive-model-3" = "https://docs.google.com/uc?id=1ABC123"
```

Large files will automatically handle the virus scan warning.

## Authentication

### Environment Variable Substitution

```toml
"s3-model" = {
    source = "url",
    url = "https://bucket.s3.amazonaws.com/model.safetensors",
    auth_header = "Bearer ${S3_TOKEN}"  # Uses $S3_TOKEN environment variable
}
```

### HuggingFace Gated Models

1. Visit the model page (e.g., `https://huggingface.co/black-forest-labs/FLUX.1-dev`)
2. Click "Agree and access repository"
3. Set `HF_TOKEN` environment variable
4. Add `gated = true` to model configuration

### CivitAI Authentication

Set `CIVITAI_TOKEN` environment variable for models requiring authentication.

## Usage

### With Vast.ai

Set environment variables in your Vast.ai instance:

```bash
PROVISION_URL=https://your-site.com/config.toml
HF_TOKEN=hf_xxxxxxxxxxxx
CIVITAI_TOKEN=xxxxxxxxx
```

### Local Testing

```bash
export PROVISION_URL="https://example.com/config.toml"
export HF_TOKEN="hf_xxxxxxxxxxxx"
export CIVITAI_TOKEN="xxxxxxxxx"

# Run container
docker run -d \
  -e PROVISION_URL \
  -e HF_TOKEN \
  -e CIVITAI_TOKEN \
  -p 8010:8010 -p 7010:7010 -p 7020:7020 -p 7030:7030 \
  ghcr.io/codechips/vastai-forge:latest
```

### Manual Execution

The provisioning script is a self-executing uv script that automatically manages its dependencies:

```bash
# Inside container
/opt/bin/provision/provision.py https://example.com/config.toml

# Or with local file
/opt/bin/provision/provision.py /path/to/config.toml

# Dependencies are automatically installed by uv when first run
```

## Logging

Provisioning logs are written to `/workspace/logs/provision.log` and include:

- Token validation results
- Download progress for each model
- Gated model access errors with instructions
- Final summary with success/failure counts

Example log output:

```
2024-01-15 10:30:00 - provision - INFO - Starting provisioning from URL: https://example.com/config.toml
2024-01-15 10:30:01 - provision - INFO - Validating authentication tokens...
2024-01-15 10:30:02 - provision - INFO - ✅ HuggingFace token is valid
2024-01-15 10:30:03 - provision - WARNING - ⚠️  CivitAI token is invalid or missing
2024-01-15 10:30:04 - provision - INFO - 📥 Downloading sdxl-base from HuggingFace
2024-01-15 10:30:05 - provision - ERROR - 🔒 GATED MODEL ACCESS DENIED
2024-01-15 10:30:05 - provision - ERROR - Model: flux-dev
2024-01-15 10:30:05 - provision - ERROR - Action: Visit https://huggingface.co/black-forest-labs/FLUX.1-dev
2024-01-15 10:30:06 - provision - INFO - ✅ Successfully downloaded sdxl-base
```

## Error Handling

The provisioning system is designed to be robust:

- **Token validation**: Checks authentication before attempting downloads
- **Graceful degradation**: Continues with accessible models if some fail
- **Clear error messages**: Provides actionable instructions for gated models
- **Partial failures**: Service startup continues even if provisioning fails
- **Resume support**: Skips already downloaded models

## Performance

- **Parallel downloads**: All models download concurrently
- **Progress tracking**: Real-time progress updates
- **Efficient transfers**: Uses `hf_transfer` for HuggingFace when available
- **Smart caching**: Skips existing models automatically

## Security

- **Token safety**: Tokens are never logged or exposed
- **URL validation**: Validates URLs before downloading
- **Safe downloads**: Proper certificate validation for HTTPS
- **Sandboxed execution**: Runs in container environment