# Ollama Azure VM - Troubleshooting Guide

## Status: ✅ **RESOLVED** - Full automation working!

This project now deploys a fully automated Ollama VM on Azure using Terraform. The deployment takes approximately 3-4 minutes and requires no manual intervention.

## Issues Resolved During Development

### 1. Cloud-init Configuration Issues (RESOLVED)
**Issue**: Initial deployment had cloud-init write_files failures
**Root Cause**: The `owner` field in write_files caused permission issues
**Solution**: Removed `owner` field and added `chown` commands in `runcmd` section

### 2. Service Configuration Issues (RESOLVED)
**Issue**: Ollama service conflicted with custom service definitions
**Root Cause**: Both default and custom systemd services trying to bind to same port
**Solution**: Configure the default service with systemd override instead:
```bash
sudo mkdir -p /etc/systemd/system/ollama.service.d
echo '[Service]' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
echo 'Environment=OLLAMA_HOST=0.0.0.0:11434' | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf
```

### 3. Model Download Issues (RESOLVED)
**Issue**: Model download failed due to user context issues
**Root Cause**: Running `ollama pull` as root without proper HOME environment
**Solution**: Execute model download as azureuser with proper HOME environment:
```bash
sudo -u azureuser HOME=/home/azureuser /usr/local/bin/ollama pull llama3.2:3b
```

### 4. Network Configuration Issues (RESOLVED)
**Issue**: Ollama only listening on localhost (127.0.0.1)
**Root Cause**: Default configuration binds to localhost only
**Solution**: Use systemd override to set `OLLAMA_HOST=0.0.0.0:11434`

## Current Working Configuration

The final working cloud-init configuration includes:

1. **Proper file creation without owner specification**
2. **Systemd service override configuration**
3. **Model download as correct user**
4. **Network binding to all interfaces**

## Testing the Deployment

### Automated Testing
The deployment is now fully automated and can be tested with:

```powershell
# Deploy
terraform apply -auto-approve

# Wait 3-4 minutes for cloud-init to complete
# Test SSH connection
ssh -i ssh_keys/ollama_vm_key azureuser@$(terraform output -raw vm_public_ip)

# Test API
ssh -i ssh_keys/ollama_vm_key azureuser@$(terraform output -raw vm_public_ip) "curl -s http://localhost:11434/api/version"

# Test model
ssh -i ssh_keys/ollama_vm_key azureuser@$(terraform output -raw vm_public_ip) 'curl -s -X POST http://localhost:11434/api/generate -d "{\"model\": \"llama3.2:3b\", \"prompt\": \"Hello\", \"stream\": false}"'
```

### Accessing the API

For security, the API is accessed via SSH tunnel:

```powershell
# Create SSH tunnel
ssh -i ssh_keys/ollama_vm_key -L 11434:localhost:11434 azureuser@$(terraform output -raw vm_public_ip) -N -f

# Test locally
curl http://localhost:11434/api/version

# Chat with model
curl -X POST http://localhost:11434/api/generate -d '{"model": "llama3.2:3b", "prompt": "Hello!", "stream": false}'
```

## Validation Script

Use the included `test-deployment.sh` script to validate the deployment:

```bash
bash test-deployment.sh
```

Or use the PowerShell script for convenient access:

```powershell
.\ollama-access.ps1
```

## Common Commands

```bash
# Check cloud-init status
sudo cloud-init status

# View cloud-init logs
sudo cat /var/log/cloud-init-output.log

# Check Ollama service
sudo systemctl status ollama

# Verify network configuration
sudo ss -tlnp | grep 11434

# List models
ollama list

# Check service configuration
sudo cat /etc/systemd/system/ollama.service.d/override.conf
```

## Files Created During Deployment

The cloud-init process creates these files:
- `/home/azureuser/install-ollama.sh` - Installation script
- `/home/azureuser/start-ollama-api.sh` - API startup script  
- `/home/azureuser/test-ollama.sh` - Testing script
- `/home/azureuser/setup-complete.txt` - Completion marker
- `/etc/systemd/system/ollama.service.d/override.conf` - Service configuration

## Expected Timeline

- **0-1 min**: VM creation and boot
- **1-2 min**: Cloud-init package installation
- **2-3 min**: Ollama installation and service configuration
- **3-4 min**: Model download (llama3.2:3b, 2.0 GB)
- **4+ min**: Ready for use

## Success Indicators

✅ `sudo cloud-init status` shows "done"  
✅ `sudo systemctl status ollama` shows "active (running)"  
✅ `sudo ss -tlnp | grep 11434` shows "*:11434" (all interfaces)  
✅ `ollama list` shows "llama3.2:3b"  
✅ `curl http://localhost:11434/api/version` returns JSON  
✅ Model responds to prompts  

The deployment is now **robust, repeatable, and fully automated**!
