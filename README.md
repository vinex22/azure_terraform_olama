# Ollama Linux VM on Azure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-blue.svg)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-blue.svg)](https://azure.microsoft.com/)
[![Ollama](https://img.shields.io/badge/Ollama-0.9.5-green.svg)](https://ollama.com/)

This project sets up a Linux virtual machine on Azure with [Ollama](https://ollama.com/) pre-installed and configured to run the llama3.2:3b model using Terraform.

**🚀 Fully automated deployment - no manual steps required!**

## Repository

📁 **GitHub**: [https://github.com/vinex22/azure_terraform_olama](https://github.com/vinex22/azure_terraform_olama)

## What This Deploys

- **Azure Resource Group**: Container for all resources
- **Virtual Network**: Isolated network for the VM
- **Network Security Group**: Firewall rules allowing SSH (22) and Ollama API (11434)
- **Linux VM**: Ubuntu 24.04 LTS with Ollama pre-installed
- **SSH Keys**: Automatically generated for secure access
- **Ollama Service**: Configured to run on all interfaces (0.0.0.0:11434)
- **Pre-downloaded Model**: llama3.2:3b model ready for use

## Prerequisites

1. **Terraform** - Install using winget:
   ```powershell
   winget install HashiCorp.Terraform
   ```

2. **Azure CLI** - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Quick Start

### 1. Configure Variables (Optional)

Copy the example variables file if you want to customize settings:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to customize your deployment:

```hcl
environment = "dev"
location = "East US"
vm_size = "Standard_D2s_v3"
ollama_model = "llama3.2:3b"
```

**Note**: SSH keys will be automatically generated and saved to the `ssh_keys/` directory.

### 2. Login to Azure

```powershell
az login
```

### 3. Deploy the Infrastructure

```powershell
# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply -auto-approve
```

### 4. Connect to Your VM

After deployment completes, use the SSH command from the Terraform output:

```powershell
# Get the connection command
terraform output ssh_connection_command

# Connect to your VM (the command will include the path to the generated SSH key)
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>
```

### 5. Use Ollama

Once connected to the VM:

```bash
# Check if setup is complete
cat setup-complete.txt

# Run Ollama interactively
./run-ollama.sh

# Test the API
./test-api.sh
```

## VM Specifications

- **OS**: Ubuntu 22.04 LTS
- **Size**: Standard_D4s_v3 (4 vCPUs, 16GB RAM)
- **Storage**: 128GB Premium SSD
- **Model**: Nous-Hermes 3B (pre-installed)

## SSH Key Management

Terraform automatically generates an SSH key pair for VM access:

- **Private Key**: `ssh_keys/ollama_vm_key` (permissions: 600)
- **Public Key**: `ssh_keys/ollama_vm_key.pub` (permissions: 644)

**Important**: 
- The SSH keys are automatically excluded from version control (see `.gitignore`)
- Keep the private key secure and don't share it
- If you lose the private key, you'll need to recreate the VM

You can view the key paths using:
```powershell
terraform output ssh_private_key_path
terraform output ssh_public_key_path
```

## Ollama API Access

The VM is configured to expose the Ollama API on port 11434. **Note**: The API is accessible from within the VM for security.

### Testing the API

```powershell
# SSH into the VM
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>

# Test API version
curl http://localhost:11434/api/version

# List available models
curl http://localhost:11434/api/tags

# Interact with the model
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:3b",
    "prompt": "Hello! Tell me about artificial intelligence.",
    "stream": false
  }'
```

### Quick Test Commands

```powershell
# Get connection info
terraform output

# Test SSH connection
ssh -i ssh_keys/ollama_vm_key azureuser@$(terraform output -raw vm_public_ip)

# Test API from within VM
ssh -i ssh_keys/ollama_vm_key azureuser@$(terraform output -raw vm_public_ip) "curl -s http://localhost:11434/api/version"

# Test model
ssh -i ssh_keys/ollama_vm_key azureuser@$(terraform output -raw vm_public_ip) 'curl -s -X POST http://localhost:11434/api/generate -d "{\"model\": \"llama3.2:3b\", \"prompt\": \"Hello\", \"stream\": false}"'
```

## Terraform Commands

### View Outputs

```powershell
terraform output
```

### Update Infrastructure

```powershell
terraform plan
terraform apply
```

### Destroy Infrastructure

```powershell
terraform destroy
```

## Customization

### Change VM Size

Edit `terraform.tfvars`:

```hcl
vm_size = "Standard_D4s_v3"
```

### Use Different Model

Edit `terraform.tfvars`:

```hcl
ollama_model = "llama2:7b"
```

### Change Location

Edit `terraform.tfvars`:

```hcl
location = "West US 2"
```

## Security Considerations

- The VM is configured with SSH key authentication only (no passwords)
- Network Security Group allows SSH (port 22) and Ollama API (port 11434) access
- Consider restricting source IP addresses in the NSG rules for production use

## Troubleshooting

### Cloud-init Status

Check if cloud-init has completed successfully:

```bash
# SSH into the VM
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>

# Check cloud-init status
sudo cloud-init status

# View detailed logs
sudo cat /var/log/cloud-init-output.log

# Check if setup completed
ls -la /home/azureuser/setup-complete.txt
```

### Ollama Service Status

```bash
# Check Ollama service status
sudo systemctl status ollama

# Check if Ollama is listening on all interfaces
sudo ss -tlnp | grep 11434
# Should show: LISTEN 0 4096 *:11434 *:* users:(("ollama",pid=XXXX,fd=3))

# View Ollama logs
sudo journalctl -u ollama --no-pager -n 50
```

### Common Issues & Solutions

#### Issue: API Not Accessible Remotely
**Symptom**: Cannot access Ollama API from outside the VM
**Solution**: 
1. Ensure Ollama is configured to listen on all interfaces (0.0.0.0:11434)
2. Check the systemd override configuration:
   ```bash
   sudo cat /etc/systemd/system/ollama.service.d/override.conf
   ```
3. Restart the service if needed:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart ollama
   ```

#### Issue: Model Not Downloaded
**Symptom**: Model pull fails during cloud-init
**Solution**:
1. Check if the model exists:
   ```bash
   ollama list
   ```
2. Manually download the model:
   ```bash
   ollama pull llama3.2:3b
   ```

#### Issue: SSH Connection Fails
**Symptom**: Cannot SSH into the VM
**Solutions**:
1. Check VM is running: `terraform output`
2. Verify SSH key permissions: `ls -la ssh_keys/`
3. Try with verbose output: `ssh -v -i ssh_keys/ollama_vm_key azureuser@<ip>`

#### Issue: Terraform Apply Fails
**Symptom**: Terraform deployment fails
**Solutions**:
1. Check Azure CLI login: `az account show`
2. Verify subscription access: `az account list`
3. Check resource quotas in the target region
4. Review Terraform error messages for specific issues

### Manual Installation (If Cloud-init Fails)

If cloud-init setup fails, you can manually install Ollama:

```bash
# SSH into the VM
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Configure to listen on all interfaces
sudo mkdir -p /etc/systemd/system/ollama.service.d
echo '[Service]' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
echo 'Environment=OLLAMA_HOST=0.0.0.0:11434' | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama

# Download the model
ollama pull llama3.2:3b
```

### Validation Script

The repository includes a test script to validate the deployment:

```bash
# Run the validation script (Linux/WSL)
bash test-deployment.sh

# Or test manually with PowerShell
$IP = (terraform output -raw vm_public_ip)
ssh -i ssh_keys/ollama_vm_key azureuser@$IP "curl -s http://localhost:11434/api/version"
```
   sudo systemctl edit ollama --full
   # Add Environment=OLLAMA_HOST=0.0.0.0:11434
   
   # Start service
   sudo systemctl enable ollama
   sudo systemctl start ollama
   
   # Pull a model
   ollama pull llama3.2:3b
   ```

### Check Terraform State

```powershell
terraform show
terraform state list
```

### Check VM Status

```bash
# SSH into the VM and check Ollama service
sudo systemctl status ollama

# Check if model is downloaded
ollama list

# View setup logs
sudo journalctl -u cloud-final
```

### Model Download Issues

If the model didn't download properly:

```bash
# Manually pull the model
ollama pull nous-hermes:3b

# Restart Ollama service
sudo systemctl restart ollama
```

### Network Connectivity Issues

If you can't access the Ollama API remotely:

1. **Check if Ollama is listening on all interfaces:**
   ```bash
   sudo netstat -tlnp | grep 11434
   ```

2. **Verify firewall rules:**
   ```bash
   sudo ufw status
   ```

3. **Test locally first:**
   ```bash
   curl http://localhost:11434/api/version
   ```

## Cost Estimation

- **VM**: Standard_D2s_v3 ~$70-100/month (varies by region)
- **Storage**: Premium SSD 128GB ~$20/month
- **Public IP**: Standard SKU ~$4/month
- **Network**: Minimal for basic usage

**Total estimated cost: ~$95-125/month**

*Note: Costs may vary by region and usage. Always check current Azure pricing.*

## Project Structure

```
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── cloud-init.yaml           # VM initialization script
├── terraform.tfvars.example  # Example variables file
├── terraform.tfvars          # Your actual variables (not in git)
└── README.md                 # This file
```

## Next Steps

1. **Experiment with different models** - Try other models available in Ollama
2. **Set up monitoring** - Add Azure Monitor or custom monitoring
3. **Implement backup** - Set up VM backup using Azure Backup
4. **Scale up** - Move to larger VM sizes for better performance
5. **Security hardening** - Implement additional security measures for production

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test the deployment: `terraform plan`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Areas for Improvement

- Support for additional Ollama models
- Multi-region deployment options
- Azure Monitor integration
- Backup and disaster recovery
- Security enhancements
- Performance optimizations

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Ollama](https://ollama.com/) for the excellent LLM deployment platform
- [HashiCorp Terraform](https://terraform.io/) for infrastructure as code
- [Azure](https://azure.microsoft.com/) for cloud infrastructure
- The open-source community for inspiration and best practices

## Support

For issues with:
- **Ollama**: [Ollama GitHub](https://github.com/ollama/ollama)
- **Terraform**: [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- **Azure deployment**: Check Azure portal or use `az` CLI
- **This template**: Create an issue in [this repository](https://github.com/vinex22/azure_terraform_olama/issues)
