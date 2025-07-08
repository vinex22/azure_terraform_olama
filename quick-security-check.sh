#!/bin/bash

# Quick Security Validation Script
# Author: Vinay Jain (https://github.com/vinex22)
# Repository: https://github.com/vinex22/azure_terraform_olama
#
# This script performs quick security checks that can be run during development

echo "🔒 Quick Security Validation"
echo "============================="

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo "✅ $message"
            ;;
        "FAIL")
            echo "❌ $message"
            ;;
        "WARN")
            echo "⚠️  $message"
            ;;
    esac
}

# Check 1: Terraform files exist
if [ -f "main.tf" ] && [ -f "variables.tf" ] && [ -f "outputs.tf" ]; then
    print_status "PASS" "All required Terraform files are present"
else
    print_status "FAIL" "Missing required Terraform files"
fi

# Check 2: SSH keys not committed
if [ -d "ssh_keys" ]; then
    print_status "FAIL" "SSH keys directory exists - ensure it's in .gitignore"
else
    print_status "PASS" "No SSH keys directory found (good for security)"
fi

# Check 3: .gitignore contains sensitive patterns
if [ -f ".gitignore" ]; then
    if grep -q "ssh_keys" .gitignore && grep -q "terraform.tfstate" .gitignore && grep -q "terraform.tfvars" .gitignore; then
        print_status "PASS" ".gitignore properly excludes sensitive files"
    else
        print_status "WARN" ".gitignore may not exclude all sensitive files"
    fi
else
    print_status "FAIL" ".gitignore file not found"
fi

# Check 4: Password authentication disabled
if grep -q "disable_password_authentication.*=.*true" main.tf 2>/dev/null; then
    print_status "PASS" "Password authentication is disabled"
else
    print_status "FAIL" "Password authentication should be disabled"
fi

# Check 5: Strong SSH keys
if grep -q "rsa_bits.*=.*4096" main.tf 2>/dev/null; then
    print_status "PASS" "SSH key uses 4096-bit RSA"
else
    print_status "WARN" "Consider using 4096-bit RSA keys"
fi

# Check 6: Network security group exists
if grep -q "azurerm_network_security_group" main.tf 2>/dev/null; then
    print_status "PASS" "Network Security Group is configured"
else
    print_status "FAIL" "Network Security Group is missing"
fi

# Check 7: No hardcoded secrets in cloud-init
if [ -f "cloud-init.yaml" ]; then
    if grep -iqE "(password|secret|key|token).*:" cloud-init.yaml; then
        print_status "WARN" "Potential hardcoded credentials in cloud-init.yaml"
    else
        print_status "PASS" "No obvious hardcoded credentials in cloud-init.yaml"
    fi
fi

# Check 8: HTTPS usage
if [ -f "cloud-init.yaml" ]; then
    if grep -qE "http://" cloud-init.yaml; then
        print_status "WARN" "Unencrypted HTTP downloads in cloud-init.yaml"
    else
        print_status "PASS" "No unencrypted HTTP downloads detected"
    fi
fi

echo ""
echo "Run './security-test.sh' for comprehensive security testing"
echo "Run 'docker run --rm -v \$(pwd):/src aquasec/tfsec:latest /src' for detailed Terraform security analysis"