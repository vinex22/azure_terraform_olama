# Security Testing Guide

**Author**: [Vinay Jain](https://github.com/vinex22)  
**Repository**: [https://github.com/vinex22/azure_terraform_olama](https://github.com/vinex22/azure_terraform_olama)

This guide explains how to test the security of your Azure Terraform Ollama deployment **without running the actual code** or deploying infrastructure.

## 🔒 Security Testing Overview

Security testing is performed through static analysis of your infrastructure code, configuration files, and scripts. This approach allows you to:

- ✅ Identify security vulnerabilities before deployment
- ✅ Validate security best practices compliance
- ✅ Ensure configuration integrity
- ✅ Check for hardcoded secrets or credentials
- ✅ Verify network security rules
- ✅ Analyze shell script security

## 🛠️ Available Security Testing Tools

### 1. Quick Security Check (Recommended for Development)
```bash
./quick-security-check.sh
```
**Purpose**: Fast security validation during development  
**Time**: ~5 seconds  
**Coverage**: Basic security checks

### 2. Comprehensive Security Test Suite
```bash
./security-test.sh
```
**Purpose**: Full security analysis with multiple tools  
**Time**: ~2-3 minutes  
**Coverage**: Complete security assessment including:
- Terraform security scanning (tfsec, Checkov)
- Shell script analysis (ShellCheck)
- YAML validation and security checks
- Network security rule analysis
- SSH configuration validation

### 3. Advanced Security Analysis
```bash
python3 security-analysis.py
```
**Purpose**: Custom security analysis with detailed reporting  
**Time**: ~10 seconds  
**Coverage**: Advanced pattern matching and security logic

## 🔍 Security Testing Categories

### 1. Infrastructure Security (Terraform)
- **Network Security Groups**: Validates proper firewall rules
- **SSH Configuration**: Ensures secure authentication
- **Disk Encryption**: Checks for encryption settings
- **Network Access**: Identifies overly permissive rules
- **Resource Tagging**: Validates governance practices

### 2. Configuration Security (YAML/Scripts)
- **Hardcoded Credentials**: Scans for embedded secrets
- **Insecure Downloads**: Identifies unencrypted HTTP transfers
- **Shell Script Security**: Analyzes for common vulnerabilities
- **YAML Syntax**: Validates configuration file integrity

### 3. Code Security (Shell Scripts)
- **Dangerous Patterns**: Identifies risky shell operations
- **Input Validation**: Checks for proper sanitization
- **File Permissions**: Validates secure file handling
- **Command Injection**: Scans for injection vulnerabilities

## 📋 Security Testing Checklist

Run this checklist before any deployment:

### Pre-Deployment Security Validation
- [ ] Run `./quick-security-check.sh` ✓
- [ ] Run `./security-test.sh` ✓
- [ ] Run `python3 security-analysis.py` ✓
- [ ] Review all WARNING and FAIL items
- [ ] Verify `.gitignore` excludes sensitive files
- [ ] Confirm no hardcoded credentials exist
- [ ] Validate network security rules
- [ ] Check SSH key configuration

### Automated Security Testing (CI/CD)
- [ ] GitHub Actions workflow includes security scanning
- [ ] tfsec security scanner passes
- [ ] Checkov policy validation passes
- [ ] ShellCheck analysis passes
- [ ] YAML validation passes

## 🚨 Common Security Issues and Fixes

### Issue 1: Overly Permissive Network Rules
**Problem**: Network Security Group allows access from any IP (0.0.0.0/0)
```hcl
# ❌ Insecure - allows access from anywhere
source_address_prefix = "*"
```
**Solution**: Restrict to specific IP ranges
```hcl
# ✅ Secure - restrict to your IP range
source_address_prefix = "203.0.113.0/24"
```

### Issue 2: Weak SSH Key Configuration
**Problem**: Using default RSA key size
```hcl
# ❌ Weak key
rsa_bits = 2048
```
**Solution**: Use stronger 4096-bit keys
```hcl
# ✅ Strong key
rsa_bits = 4096
```

### Issue 3: Password Authentication Enabled
**Problem**: VM allows password authentication
```hcl
# ❌ Insecure
disable_password_authentication = false
```
**Solution**: Disable password authentication
```hcl
# ✅ Secure
disable_password_authentication = true
```

### Issue 4: Hardcoded Credentials in YAML
**Problem**: Credentials stored in configuration files
```yaml
# ❌ Never do this
password: "mySecretPassword123"
api_key: "abc123def456"
```
**Solution**: Use Azure Key Vault or environment variables
```yaml
# ✅ Secure approach
# Use Azure Key Vault integration or pass via environment
```

## 🔧 Tool-Specific Security Testing

### Using tfsec (Terraform Security Scanner)
```bash
# Run with Docker (recommended)
docker run --rm -v $(pwd):/src aquasec/tfsec:latest /src

# Install locally (alternative)
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
tfsec .
```

### Using Checkov (Policy as Code)
```bash
# Run with Docker
docker run --rm -v $(pwd):/tf bridgecrew/checkov -f /tf/main.tf --framework terraform

# Install with pip
pip3 install checkov
checkov -f main.tf --framework terraform
```

### Using ShellCheck (Shell Script Analysis)
```bash
# Install on Ubuntu/Debian
sudo apt-get install shellcheck

# Analyze all shell scripts
for script in *.sh; do shellcheck "$script"; done
```

## 📊 Understanding Security Test Results

### Exit Codes
- **0**: All tests passed ✅
- **1**: Warnings found (review recommended) ⚠️
- **2**: Critical issues found (must fix before deployment) ❌

### Severity Levels
- **CRITICAL**: Immediate security risk, deployment blocked
- **HIGH**: Significant security concern, should be fixed
- **MEDIUM**: Security improvement recommended
- **LOW**: Best practice suggestion

## 🎯 Production Security Checklist

Before deploying to production:

### Infrastructure Security
- [ ] Network access restricted to necessary IPs only
- [ ] Disk encryption enabled
- [ ] Azure Security Center enabled
- [ ] Just-in-time VM access configured
- [ ] Network Security Groups properly configured

### Operational Security
- [ ] Automated backup configured
- [ ] Monitoring and alerting set up
- [ ] Log collection enabled
- [ ] Security updates automated
- [ ] Access control policies defined

### Compliance and Governance
- [ ] Resource tagging implemented
- [ ] Cost monitoring enabled
- [ ] Compliance policies enforced
- [ ] Security documentation updated
- [ ] Incident response plan ready

## 🚀 Integration with CI/CD

The repository includes GitHub Actions workflow that automatically runs security tests on every push/PR:

1. **Terraform Validation**: Syntax and format checking
2. **Security Scanning**: tfsec and Checkov analysis
3. **Shell Script Analysis**: ShellCheck validation
4. **YAML Validation**: Configuration file integrity
5. **Comprehensive Testing**: Full security test suite

View results in the GitHub Actions tab of your repository.

## 📚 Additional Security Resources

### Azure Security Documentation
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/)
- [Azure Network Security](https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)
- [Azure VM Security](https://docs.microsoft.com/en-us/azure/virtual-machines/security-recommendations)

### Security Tools Documentation
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)
- [Checkov Documentation](https://www.checkov.io/1.Welcome/Quick%20Start.html)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck)

### Terraform Security Guides
- [Terraform Security Best Practices](https://blog.gruntwork.io/terraform-security-best-practices-6f63a5e1cd57)
- [Securing Terraform](https://blog.gitguardian.com/securing-terraform/)

## 🆘 Troubleshooting Security Tests

### Common Issues

1. **Docker not available**: Install Docker or use alternative installation methods
2. **Permission denied**: Ensure scripts are executable (`chmod +x script.sh`)
3. **Python dependencies**: Install PyYAML (`pip3 install PyYAML`)
4. **Network timeouts**: Check internet connection for tool downloads

### Getting Help

If you encounter issues with security testing:

1. Check the tool's documentation (links provided above)
2. Review the error messages carefully
3. Ensure all dependencies are installed
4. Try running individual tools separately to isolate issues

## 🎉 Conclusion

Security testing without deployment provides confidence that your infrastructure code follows security best practices. Regular security validation helps prevent vulnerabilities from reaching production environments.

Remember: **Security is not a one-time check but an ongoing process.** Integrate these security tests into your development workflow for continuous security validation.