# Local Testing Guide for Provisioning System

This guide explains how to test the provisioning system locally without Docker.

## Prerequisites

- Python 3.10+
- `uv` package manager installed
- Optional: HuggingFace and CivitAI tokens

## Quick Start

### 1. Run the Test Setup Script

```bash
./test_provision_local.sh
```

This creates a test environment at `/tmp/vastai-forge-test` with:
- Model directories structure
- Test configuration file
- Log directory

### 2. Test with Minimal Configuration

```bash
# Test with tiny files (no auth required)
./scripts/provision/provision.py examples/test-provision-minimal.toml
```

### 3. View Results

```bash
# Check downloaded models
ls -la /tmp/vastai-forge-test/models/*/

# View logs
cat /tmp/vastai-forge-test/logs/provision.log
```

## Testing Different Scenarios

### Testing with Custom Workspace

```bash
export WORKSPACE="/path/to/custom/workspace"
./scripts/provision/provision.py examples/test-provision-minimal.toml
```

### Testing with Authentication

```bash
# Set tokens
export HF_TOKEN="hf_xxxxxxxxxxxx"
export CIVITAI_TOKEN="xxxxxxxxx"

# Run with full config
./scripts/provision/provision.py examples/test-provision-full.toml
```

### Testing with Remote URL

```bash
# Start local web server
cd examples
python -m http.server 8000

# In another terminal
./scripts/provision/provision.py http://localhost:8000/test-provision-minimal.toml
```

### Testing Gated Models

1. First, accept Terms of Service on HuggingFace:
   - Visit: https://huggingface.co/black-forest-labs/FLUX.1-dev
   - Click "Agree and access repository"

2. Set your HF token:
   ```bash
   export HF_TOKEN="hf_xxxxxxxxxxxx"
   ```

3. Test with gated model config:
   ```bash
   ./scripts/provision/provision.py examples/provision-config.toml
   ```

## Debugging

### Enable Debug Logging

```bash
# Set Python logging level
export PYTHONUNBUFFERED=1
export PYTHONASYNCIODEBUG=1

# Run with verbose output
./scripts/provision/provision.py -v examples/test-provision-minimal.toml
```

### Common Issues

**uv not found**
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Permission denied**
```bash
chmod +x scripts/provision/provision.py
```

**Module not found errors**
```bash
# The script should auto-install dependencies, but if not:
cd scripts/provision
uv pip install aiohttp tomli huggingface_hub[hf_transfer]
```

**Token validation failures**
- Ensure tokens are valid and exported correctly
- Check token permissions (write access may be needed)
- For HF gated models, ensure TOS is accepted

## Testing Specific Features

### Test Google Drive URLs

```toml
[models.checkpoints]
"gdrive-test" = {
    source = "url",
    url = "https://drive.google.com/file/d/YOUR_FILE_ID/view",
    filename = "test-model.safetensors"
}
```

### Test Parallel Downloads

Create config with multiple models:
```toml
[models.lora]
"model1" = "https://example.com/model1.safetensors"
"model2" = "https://example.com/model2.safetensors"
"model3" = "https://example.com/model3.safetensors"
```

### Test Error Handling

```toml
[models.checkpoints]
# This will fail gracefully
"nonexistent" = {
    source = "huggingface",
    repo = "nonexistent/repo",
    file = "model.safetensors"
}
```

## Clean Up

```bash
# Remove test environment
rm -rf /tmp/vastai-forge-test

# Or keep models and just remove logs
rm -rf /tmp/vastai-forge-test/logs
```

## Advanced Testing

### Custom Progress Tracking

```python
# Monitor progress in real-time
tail -f /tmp/vastai-forge-test/logs/provision.log
```

### Test with Docker Environment

```bash
# Simulate Docker environment
export WORKSPACE=/workspace
export PUBLIC_IPADDR=0.0.0.0
export PASSWORD=admin
export USERNAME=admin

./scripts/provision/provision.py examples/test-provision-minimal.toml
```

### Performance Testing

```bash
# Time the downloads
time ./scripts/provision/provision.py examples/test-provision-full.toml

# Monitor network usage
nethogs -d 1
```

## Creating Test Configurations

### Minimal Test (Fast)
- Use small files (<1MB)
- Public models only
- Test basic functionality

### Integration Test (Medium)
- Mix of sources (HF, CivitAI, URLs)
- Some authentication required
- Medium-sized files (10-100MB)

### Full Test (Slow)
- Large models (GB+)
- Gated models
- All features enabled

## Tips

1. **Start small**: Use minimal config first
2. **Check logs**: Detailed progress in provision.log
3. **Test incrementally**: Add one model at a time
4. **Use test tokens**: Create test accounts if needed
5. **Monitor disk space**: Large models need significant space

## Example Test Session

```bash
# 1. Setup
./test_provision_local.sh

# 2. Test basic functionality
export WORKSPACE=/tmp/vastai-forge-test
./scripts/provision/provision.py examples/test-provision-minimal.toml

# 3. Check results
ls -la /tmp/vastai-forge-test/models/checkpoints/
cat /tmp/vastai-forge-test/logs/provision.log | grep "Successfully downloaded"

# 4. Test with auth
export HF_TOKEN="hf_xxxxxxxxxxxx"
./scripts/provision/provision.py examples/provision-config.toml

# 5. Clean up
rm -rf /tmp/vastai-forge-test
```