# 🦙✨ Ollama Linux VM on Azure with Terraform ✨🚀

<div align="center">

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-blue.svg)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-blue.svg)](https://azure.microsoft.com/)
[![Ollama](https://img.shields.io/badge/Ollama-0.9.5-green.svg)](https://ollama.com/)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/vinex22/azure_terraform_olama?style=social)](https://github.com/vinex22/azure_terraform_olama)

</div>

<div align="center">

🎯 **One-Click AI Deployment** 🎯

**🔥 Deploy a powerful AI server in minutes - zero manual setup required! 🔥**

✨ *Terraform + Azure + Ollama = AI Magic* ✨

</div>

---

## 🎊 What's This About? 🎊

This project automates the deployment of a Linux virtual machine on Azure with [Ollama](https://ollama.com/) pre-installed and configured to run the llama3.2:3b model using Terraform. Think of it as your personal AI assistant in the cloud! 🤖☁️

## 🏠 Repository & Author 🏠

<div align="center">

📁 **GitHub Repository**: [https://github.com/vinex22/azure_terraform_olama](https://github.com/vinex22/azure_terraform_olama)  
�‍💻 **Created by**: [Vinay Jain](https://github.com/vinex22) 👨‍💻  
💝 **License**: MIT  
⭐ **Star this repo if you like it!** ⭐

</div>

---

## � What Magic Does This Deploy? 🎁

<div align="center">

| 🏗️ Component | 📋 Description | 🎯 Purpose |
|---------------|----------------|-------------|
| 🏢 **Azure Resource Group** | Container for all resources | 📦 Keeps everything organized |
| 🌐 **Virtual Network** | Isolated network for the VM | 🛡️ Security & isolation |
| 🚪 **Network Security Group** | Firewall rules (SSH:22, API:11434) | 🔒 Controlled access |
| 🖥️ **Linux VM** | Ubuntu 24.04 LTS powerhouse | 💪 Your AI compute engine |
| 🔐 **SSH Keys** | Auto-generated security keys | 🗝️ Secure passwordless access |
| ⚡ **Ollama Service** | AI model serving platform | 🤖 The AI brain |
| 🧠 **Pre-downloaded Model** | llama3.2:3b ready to chat | 💬 Instant AI conversations |

</div>

---

## �️ Prerequisites & Setup 🛠️

### 💻 What You Need 💻

<div align="center">

🔧 **Terraform** ➕ ☁️ **Azure CLI** ➕ 💳 **Azure Subscription**

</div>

#### 🎯 Step 1: Install Terraform 🎯

```powershell
# 🚀 Easy installation with winget
winget install HashiCorp.Terraform

# 🔍 Verify installation
terraform --version
```

#### 🎯 Step 2: Install Azure CLI 🎯

```powershell
# 🌐 Download from Microsoft
# Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# 🔍 Verify installation
az --version
```

---

## 🚀 Launch Your AI Server! 🚀

### 🎊 The Fun Begins Here! 🎊

#### 🔥 Option 1: Quick Deploy (Recommended) 🔥

```powershell
# 🎯 One-liner magic (uses defaults)
terraform init && terraform validate && terraform plan && terraform apply -auto-approve
```

#### 🎨 Option 2: Custom Deploy (For Power Users) 🎨

```powershell
# 🎨 Copy and customize settings
Copy-Item terraform.tfvars.example terraform.tfvars

# ✏️ Edit to your heart's content
notepad terraform.tfvars
```

**🎛️ Available customizations:**
```hcl
environment = "production"  # 🏷️ Your deployment tag
location = "West US 2"      # 🌍 Pick your region
vm_size = "Standard_D4s_v3" # � More power = more fun!
```

---

## 🎮 Time to Play! 🎮

### 🔑 Step 1: Login to Azure 🔑

```powershell
# 🚪 Open the Azure gateway
az login

# 🕵️ Check your subscription
az account show
```

### 🚀 Step 2: Deploy Your AI Empire 🚀

```powershell
# 🎯 Initialize the magic
terraform init

# 🔍 Validate your configuration
terraform validate

# 📋 See what will be created
terraform plan

# 🚀 DEPLOY! (The exciting part!)
terraform apply -auto-approve
```

### 🎉 Step 3: Connect to Your AI Server 🎉

```powershell
# 🔍 Get your connection details
terraform output

# 🔗 Connect via SSH (auto-generated command)
ssh -i ssh_keys/ollama_vm_key azureuser@<your-shiny-new-vm-ip>
```

### 🤖 Step 4: Chat with Your AI! 🤖

```bash
# 🎊 Welcome to your AI server!
# 🔍 Check if everything is ready
cat setup-complete.txt

# 🎮 Start chatting with AI
./run-ollama.sh

# 🧪 Test the API
./test-api.sh
```

---

## 🎯 VM Specifications (Your AI Beast!) 🎯

<div align="center">

| 🏷️ Spec | 📊 Value | 🎯 Why It's Awesome |
|----------|----------|---------------------|
| 💿 **OS** | Ubuntu 22.04 LTS | 🛡️ Rock-solid stability |
| ⚡ **Power** | Standard_D4s_v3 | 💪 4 vCPUs, 16GB RAM |
| 💾 **Storage** | 128GB Premium SSD | 🚀 Lightning fast I/O |
| 🤖 **AI Model** | llama3.2:3b | 🧠 Smart & responsive |
| 🌐 **Network** | Public IP + Private VNet | 🔒 Secure yet accessible |

</div>

---

## � SSH Key Magic 🔐

<div align="center">

🎩✨ **Auto-generated SSH keys - no passwords needed!** ✨🎩

</div>

🔑 **Your Keys:**
- **� Private Key**: `ssh_keys/ollama_vm_key` (Keep it secret! 🤫)
- **🔓 Public Key**: `ssh_keys/ollama_vm_key.pub` (Share safely! 📤)

```powershell
# 🔍 Check your key locations
terraform output ssh_private_key_path
terraform output ssh_public_key_path
```

⚠️ **Important Security Notes:**
- 🚫 SSH keys are auto-excluded from git (safe!)
- 🔐 Private key = your server access (guard it!)
- � Lost key = need new VM (backup recommended!)

---

## 🌐 API Access & Testing 🌐

<div align="center">

🎯 **Your AI is running on port 11434** 🎯

</div>

### 🧪 Quick API Tests 🧪

```powershell
# 🔗 Get your VM IP
$IP = (terraform output -raw vm_public_ip)

# 🔍 Test API version
ssh -i ssh_keys/ollama_vm_key azureuser@$IP "curl -s http://localhost:11434/api/version"

# 📋 List available models
ssh -i ssh_keys/ollama_vm_key azureuser@$IP "curl -s http://localhost:11434/api/tags"

# 🤖 Chat with your AI!
ssh -i ssh_keys/ollama_vm_key azureuser@$IP 'curl -s -X POST http://localhost:11434/api/generate -d "{\"model\": \"llama3.2:3b\", \"prompt\": \"Hello! Tell me a joke about Azure and AI.\", \"stream\": false}"'
```

### 🎊 Interactive API Testing 🎊

```bash
# 🚀 SSH into your server
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>

# 🔍 Check API health
curl http://localhost:11434/api/version

# 🎮 Start an interactive session
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:3b",
    "prompt": "Write a haiku about cloud computing",
    "stream": false
  }'
```

---

## 🎛️ Terraform Command Center 🎛️

<div align="center">

🎯 **Your Infrastructure Control Panel** 🎯

</div>

### 👁️ Information Commands 👁️

```powershell
# 📊 View all outputs
terraform output

# 📋 Show current state
terraform show

# 📝 List all resources
terraform state list
```

### 🔄 Management Commands 🔄

```powershell
# 🔄 Plan changes
terraform plan

# ⚡ Apply changes
terraform apply

# 🔄 Refresh state
terraform refresh

# 💾 Format code
terraform fmt
```

### 💥 Destruction Commands 💥

```powershell
# 🚨 DANGER ZONE! 🚨
# 💥 Destroy everything (careful!)
terraform destroy

# 🎯 Destroy specific resource
terraform destroy -target=azurerm_virtual_machine.main
```

---

## 🎨 Customization Corner 🎨

<div align="center">

🎯 **Make it YOUR way!** 🎯

</div>

### 💪 Upgrade Your VM Power 💪

```hcl
# 🚀 For more AI power!
vm_size = "Standard_D8s_v3"  # 8 vCPUs, 32GB RAM 🔥
vm_size = "Standard_D16s_v3" # 16 vCPUs, 64GB RAM 💪
vm_size = "Standard_D32s_v3" # 32 vCPUs, 128GB RAM 🚀
```

### 🌍 Pick Your Region 🌍

```hcl
# 🗺️ Choose your location
location = "East US"         # 🇺🇸 US East Coast
location = "West US 2"       # 🇺🇸 US West Coast  
location = "West Europe"     # 🇪🇺 Europe
location = "Southeast Asia"  # 🌏 Asia Pacific
```

### 🏷️ Name Your Environment 🏷️

```hcl
# 🎨 Custom naming
environment = "production"   # 🏭 For serious stuff
environment = "development"  # 🛠️ For experimenting
environment = "ai-playground" # 🎮 For fun!
```

---

## 🔒 Security & Best Practices 🔒

<div align="center">

🛡️ **Security First!** 🛡️

</div>

### 🎯 Current Security Features 🎯

- ✅ **SSH Key Authentication** (no passwords!)
- ✅ **Network Security Groups** (controlled access)
- ✅ **Private networking** (secure communication)
- ✅ **Automatic updates** (stay current)

### 🚨 Production Security Checklist 🚨

- [ ] 🔒 Restrict SSH access to specific IPs
- [ ] 🌐 Use VPN for API access
- [ ] 🔐 Enable Azure Monitor
- [ ] 💾 Set up automated backups
- [ ] 🚨 Configure alerting
- [ ] 🛡️ Enable just-in-time access

---

## 🚨 Troubleshooting Corner 🚨

<div align="center">

🔧 **Don't panic! We've got you covered!** 🔧

</div>

### 🔍 Cloud-init Status Check 🔍

```bash
# 🚀 SSH into your server
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>

# 🔍 Check if cloud-init finished
sudo cloud-init status

# 📝 View the setup logs
sudo cat /var/log/cloud-init-output.log

# ✅ Confirm setup completed
ls -la /home/azureuser/setup-complete.txt
```

### 🤖 Ollama Service Diagnostics 🤖

```bash
# 🔍 Check service status
sudo systemctl status ollama

# 🌐 Verify network listening
sudo ss -tlnp | grep 11434
# Should show: 🎯 LISTEN 0 4096 *:11434 *:*

# 📋 View service logs
sudo journalctl -u ollama --no-pager -n 50
```

### 🚨 Common Issues & Super Solutions 🚨

#### 🔥 Issue: API Not Accessible Remotely 🔥

**😱 Symptom**: Can't reach Ollama API from outside
**🎯 Solution**: 
```bash
# 🔧 Check Ollama configuration
sudo cat /etc/systemd/system/ollama.service.d/override.conf

# 🔄 Restart if needed
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

#### 🤖 Issue: Model Not Downloaded 🤖

**😵 Symptom**: No AI model available
**🎯 Solution**:
```bash
# 📋 Check available models
ollama list

# 📥 Download manually
ollama pull llama3.2:3b
```

#### 🔐 Issue: SSH Connection Fails 🔐

**🚫 Symptom**: Can't connect to VM
**🎯 Solutions**:
```powershell
# 🔍 Check VM status
terraform output

# 🔐 Verify SSH key permissions
ls -la ssh_keys/

# 🕵️ Debug connection
ssh -v -i ssh_keys/ollama_vm_key azureuser@<ip>
```

#### 💥 Issue: Terraform Deployment Fails 💥

**⚠️ Symptom**: Terraform apply fails
**🎯 Solutions**:
```powershell
# 🔑 Check Azure login
az account show

# 📋 List subscriptions
az account list

# 🔍 Check resource quotas
az vm list-usage --location "East US"
```

### 🛠️ Manual Installation (Emergency Mode) 🛠️

```bash
# 🚀 If cloud-init fails, do this manually
ssh -i ssh_keys/ollama_vm_key azureuser@<your-vm-ip>

# 📥 Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# ⚙️ Configure for all interfaces
sudo mkdir -p /etc/systemd/system/ollama.service.d
echo '[Service]' | sudo tee /etc/systemd/system/ollama.service.d/override.conf
echo 'Environment=OLLAMA_HOST=0.0.0.0:11434' | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf

# 🔄 Start services
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama

# 🤖 Download your AI model
ollama pull llama3.2:3b
```

---

## 💰 Cost Breakdown (Budget Planning) 💰

<div align="center">

💡 **Know before you deploy!** 💡

</div>

| 🏷️ Component | 💵 Monthly Cost | 📊 Usage |
|---------------|------------------|----------|
| 🖥️ **VM (Standard_D4s_v3)** | ~$120-150 | 💪 4 vCPUs, 16GB RAM |
| 💾 **Premium SSD (128GB)** | ~$20-25 | 🚀 High-speed storage |
| 🌐 **Public IP** | ~$4-6 | 📡 Internet access |
| 🔄 **Network Transfer** | ~$1-10 | 📊 Depends on usage |
| **🎯 Total Estimated** | **~$145-190** | 💡 Varies by region |

💡 **Cost Optimization Tips:**
- 🔄 Use B-series burstable VMs for lighter workloads
- 💾 Standard SSD is cheaper than Premium
- 🌍 Some regions are more cost-effective
- ⏰ Consider auto-shutdown for dev environments

---

## 📁 Project Structure (The Anatomy) 📁

<div align="center">

🎯 **Clean, organized, and professional!** 🎯

</div>

```
📦 azure_terraform_olama/
├── 🏗️ main.tf                    # Main infrastructure code
├── 📝 variables.tf               # Configuration variables
├── 📤 outputs.tf                 # What you get after deployment
├── ☁️ cloud-init.yaml           # VM initialization magic
├── 📋 terraform.tfvars.example  # Example configuration
├── 🔐 terraform.tfvars          # Your actual settings (gitignored)
├── 🔑 ssh_keys/                 # Auto-generated SSH keys
├── 📚 README.md                 # This awesome guide
├── 🚨 TROUBLESHOOTING.md       # Detailed problem solving
├── 📖 PROJECT_STRUCTURE.md     # Architecture documentation
├── ⚖️ LICENSE                   # MIT License
├── 🧪 test-deployment.sh        # Validation script
├── 💻 ollama-access.ps1         # Windows PowerShell helper
├── 🚫 .gitignore               # What stays private
└── 🔄 .github/workflows/       # CI/CD automation
    └── terraform.yml            # Terraform validation
```

---

## 🎯 Next Level Adventures 🎯

<div align="center">

🚀 **Ready to level up?** 🚀

</div>

### 🎮 Immediate Fun Activities 🎮

1. 🤖 **Try Different Models** - Explore Ollama's model zoo
2. 🎨 **Customize Prompts** - Create your own AI personalities  
3. 🔗 **API Integration** - Connect to your favorite apps
4. 📊 **Performance Testing** - See how fast your AI responds

### 🏗️ Advanced Implementations 🏗️

1. 📊 **Azure Monitor Integration** - Track performance metrics
2. 💾 **Automated Backups** - Protect your AI investment
3. 🔄 **Load Balancing** - Multiple AI instances  
4. 🌐 **Custom Domain** - Professional API endpoints
5. 🔒 **VPN Integration** - Enterprise-grade security

### 🎯 Production Enhancements 🎯

1. 🚨 **Alerting & Monitoring** - Know when issues occur
2. 🔐 **Security Hardening** - Lock down for production
3. 📈 **Auto-scaling** - Handle traffic spikes
4. 🌍 **Multi-region** - Global AI availability
5. 💼 **Disaster Recovery** - Business continuity

---

## 🤝 Contributing & Community 🤝

<div align="center">

🎊 **Join the fun! Make it better!** 🎊

</div>

### 🚀 How to Contribute 🚀

1. 🍴 **Fork** the repository
2. 🌿 **Create** a feature branch: `git checkout -b feature/amazing-ai-feature`
3. 💻 **Code** your improvements
4. 🧪 **Test** thoroughly: `terraform plan && terraform apply`
5. 📝 **Commit** with style: `git commit -m '✨ Add amazing AI feature'`
6. 📤 **Push** to your branch: `git push origin feature/amazing-ai-feature`
7. 🎉 **Open** a Pull Request

### 🎯 Areas We'd Love Help With 🎯

- 🤖 **More AI Models** - Support for additional models
- 🌍 **Multi-region** - Global deployment options
- 📊 **Monitoring** - Azure Monitor integration
- 🔒 **Security** - Advanced security features
- 🎨 **UI/UX** - Web interface for Ollama
- 📖 **Documentation** - More examples and guides

### 💡 Ideas & Suggestions 💡

Got a crazy idea? We love crazy ideas! 🤪
- 🎯 Open an issue to discuss
- 💬 Start a discussion
- 📧 Reach out to the author

---

## 📜 License & Legal Stuff 📜

<div align="center">

⚖️ **MIT License - Use it, modify it, share it!** ⚖️

</div>

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**🎯 TL;DR**: You can do whatever you want with this code! 🎉

---

## 🌟 Acknowledgments & Credits 🌟

<div align="center">

🙏 **Standing on the shoulders of giants!** 🙏

</div>

### 👨‍💻 Project Creator 👨‍💻

- **🎯 Vinay Jain** - [GitHub](https://github.com/vinex22) | [LinkedIn](https://linkedin.com/in/vinay-jain)
  - 💡 Original idea and implementation
  - 🏗️ Infrastructure architecture
  - 📖 Documentation and guides
  - 🎯 Ongoing maintenance and support

### 🏆 Technology Partners 🏆

- 🦙 **[Ollama](https://ollama.com/)** - The amazing AI platform
- 🏗️ **[HashiCorp Terraform](https://terraform.io/)** - Infrastructure as Code
- ☁️ **[Microsoft Azure](https://azure.microsoft.com/)** - Cloud infrastructure
- 🐧 **[Ubuntu](https://ubuntu.com/)** - Reliable Linux foundation

### 🤝 Community Contributors 🤝

- 🌟 **Future contributors** - That could be YOU!
- 💡 **Issue reporters** - Helping make it better
- 🔧 **Pull request authors** - Adding awesome features
- 📖 **Documentation improvers** - Making it clearer

---

## 🆘 Support & Help 🆘

<div align="center">

🚨 **Need help? We're here for you!** 🚨

</div>

### 🎯 For Different Types of Issues 🎯

| 🔥 Issue Type | 🎯 Where to Get Help | 📱 How to Reach |
|---------------|---------------------|------------------|
| 🦙 **Ollama Issues** | [Ollama GitHub](https://github.com/ollama/ollama) | 🐛 Report bugs, ask questions |
| 🏗️ **Terraform Issues** | [Terraform Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) | 📚 Check documentation |
| ☁️ **Azure Issues** | Azure Portal / Azure CLI | 🔧 Use built-in diagnostics |
| 🎯 **This Template** | [Our Issues Page](https://github.com/vinex22/azure_terraform_olama/issues) | 🐛 Report template-specific issues |

### 🚀 Quick Support Channels 🚀

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/vinex22/azure_terraform_olama/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/vinex22/azure_terraform_olama/discussions)
- 📖 **Documentation**: Check our [wiki](https://github.com/vinex22/azure_terraform_olama/wiki)
- 💬 **Community Chat**: Join our discussions

---

<div align="center">

# 🎉 Happy AI Deployment! 🎉

### 🚀 **Go forth and create amazing AI experiences!** 🚀

---

⭐ **Don't forget to star this repo if it helped you!** ⭐

📢 **Share it with your friends and colleagues!** 📢

🚀 **Deploy responsibly and have fun!** 🚀

---

*Made with ❤️ by [Vinay Jain](https://github.com/vinex22) | Powered by ☁️ Azure + 🏗️ Terraform + 🦙 Ollama*

</div>
