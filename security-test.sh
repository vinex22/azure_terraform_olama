#!/bin/bash

# Security Testing Script for Ollama Azure Terraform Deployment
# Author: Vinay Jain (https://github.com/vinex22)
# Repository: https://github.com/vinex22/azure_terraform_olama
#
# This script performs comprehensive security testing without deploying infrastructure
# It validates Terraform configurations, shell scripts, and YAML files for security issues

set -e

echo "🔒 Azure Terraform Ollama - Security Testing Suite 🔒"
echo "======================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for test results
PASSED=0
FAILED=0
WARNINGS=0

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✓ PASS${NC}: $message"
            ((PASSED++))
            ;;
        "FAIL")
            echo -e "${RED}✗ FAIL${NC}: $message"
            ((FAILED++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠ WARN${NC}: $message"
            ((WARNINGS++))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ INFO${NC}: $message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "🔍 Phase 1: Environment and Dependencies Check"
echo "=============================================="

# Check required tools
print_status "INFO" "Checking security testing dependencies..."

if command_exists docker; then
    print_status "PASS" "Docker is available for security scanning"
else
    print_status "FAIL" "Docker not found - required for some security scanners"
fi

if command_exists shellcheck; then
    print_status "PASS" "ShellCheck is available for shell script analysis"
else
    print_status "WARN" "ShellCheck not found - shell script security validation will be limited"
fi

if command_exists python3; then
    print_status "PASS" "Python3 is available for custom security checks"
else
    print_status "FAIL" "Python3 not found - required for some security validations"
fi

echo ""
echo "🔧 Phase 2: Terraform Security Analysis"
echo "======================================="

# Terraform format check
if [ -f "main.tf" ]; then
    print_status "INFO" "Checking Terraform code formatting..."
    if docker run --rm -v "$(pwd)":/data -w /data hashicorp/terraform:1.5.0 fmt -check -diff >/dev/null 2>&1; then
        print_status "PASS" "Terraform code is properly formatted"
    else
        print_status "WARN" "Terraform code formatting issues detected"
        echo "Run 'terraform fmt' to fix formatting"
    fi
else
    print_status "FAIL" "main.tf not found"
fi

# Terraform validation using Docker
print_status "INFO" "Validating Terraform configuration..."
if [ -f "main.tf" ]; then
    # Create a temporary terraform.tfvars for validation
    cat > "$TEMP_DIR/terraform.tfvars" << EOF
environment = "security-test"
location = "East US"
vm_size = "Standard_B2s"
EOF
    
    # Run terraform init and validate in Docker
    if docker run --rm -v "$(pwd)":/data -v "$TEMP_DIR/terraform.tfvars":/data/terraform.tfvars -w /data hashicorp/terraform:1.5.0 sh -c "terraform init -backend=false >/dev/null 2>&1 && terraform validate" >/dev/null 2>&1; then
        print_status "PASS" "Terraform configuration is valid"
    else
        print_status "FAIL" "Terraform configuration validation failed"
    fi
else
    print_status "FAIL" "No Terraform files found for validation"
fi

# Security scanning with tfsec
print_status "INFO" "Running tfsec security scanner..."
if docker run --rm -v "$(pwd)":/src aquasec/tfsec:latest /src --no-color --format json > "$TEMP_DIR/tfsec-results.json" 2>/dev/null; then
    # Parse tfsec results
    if python3 -c "
import json
import sys
try:
    with open('$TEMP_DIR/tfsec-results.json', 'r') as f:
        data = json.load(f)
    
    if 'results' in data and data['results']:
        critical = len([r for r in data['results'] if r.get('severity', '').upper() == 'CRITICAL'])
        high = len([r for r in data['results'] if r.get('severity', '').upper() == 'HIGH'])
        medium = len([r for r in data['results'] if r.get('severity', '').upper() == 'MEDIUM'])
        low = len([r for r in data['results'] if r.get('severity', '').upper() == 'LOW'])
        
        print(f'Found {critical} critical, {high} high, {medium} medium, {low} low severity issues')
        
        if critical > 0:
            sys.exit(2)  # Critical issues
        elif high > 0:
            sys.exit(1)  # High severity issues
        else:
            sys.exit(0)  # No critical/high issues
    else:
        print('No security issues found')
        sys.exit(0)
except Exception as e:
    print(f'Error parsing tfsec results: {e}')
    sys.exit(3)
" 2>/dev/null; then
        print_status "PASS" "No critical or high severity security issues found by tfsec"
    else
        case $? in
            1)
                print_status "WARN" "High severity security issues found by tfsec"
                ;;
            2)
                print_status "FAIL" "Critical security issues found by tfsec"
                ;;
            *)
                print_status "WARN" "tfsec completed with warnings or errors"
                ;;
        esac
        echo "Check tfsec output for details: docker run --rm -v \$(pwd):/src aquasec/tfsec:latest /src"
    fi
else
    print_status "WARN" "tfsec security scanner failed to run"
fi

# Security scanning with Checkov
print_status "INFO" "Running Checkov security scanner..."
if docker run --rm -v "$(pwd)":/tf bridgecrew/checkov -f /tf/main.tf --framework terraform --quiet --compact 2>/dev/null | tail -n 20 > "$TEMP_DIR/checkov-results.txt"; then
    if grep -q "FAILED" "$TEMP_DIR/checkov-results.txt"; then
        CHECKOV_FAILED=$(grep "FAILED" "$TEMP_DIR/checkov-results.txt" | wc -l)
        print_status "WARN" "Checkov found $CHECKOV_FAILED security policy violations"
        echo "Run 'docker run --rm -v \$(pwd):/tf bridgecrew/checkov -f /tf/main.tf --framework terraform' for details"
    else
        print_status "PASS" "Checkov security scan completed without major issues"
    fi
else
    print_status "WARN" "Checkov security scanner failed to run"
fi

echo ""
echo "🐚 Phase 3: Shell Script Security Analysis"
echo "=========================================="

# Check all shell scripts with shellcheck
for script in *.sh; do
    if [ -f "$script" ]; then
        print_status "INFO" "Analyzing shell script: $script"
        if command_exists shellcheck; then
            if shellcheck -f gcc "$script" 2>/dev/null; then
                print_status "PASS" "Shell script $script passed security analysis"
            else
                print_status "WARN" "Shell script $script has potential security issues"
                echo "Run 'shellcheck $script' for details"
            fi
        else
            print_status "WARN" "Cannot analyze $script - shellcheck not available"
        fi
    fi
done

# Check for common security anti-patterns in shell scripts
print_status "INFO" "Checking for shell script security anti-patterns..."
SECURITY_ISSUES=0

for script in *.sh; do
    if [ -f "$script" ]; then
        # Check for unsafe practices
        if grep -q "curl.*|.*sh" "$script"; then
            print_status "WARN" "$script: Piping curl output directly to shell (security risk)"
            ((SECURITY_ISSUES++))
        fi
        
        if grep -q "\$\$" "$script"; then
            print_status "WARN" "$script: Process ID usage detected (potential security concern)"
            ((SECURITY_ISSUES++))
        fi
        
        if grep -q "eval" "$script"; then
            print_status "WARN" "$script: eval usage detected (security risk)"
            ((SECURITY_ISSUES++))
        fi
        
        if grep -qE "(wget|curl).*http://" "$script"; then
            print_status "WARN" "$script: Unencrypted HTTP downloads detected"
            ((SECURITY_ISSUES++))
        fi
    fi
done

if [ $SECURITY_ISSUES -eq 0 ]; then
    print_status "PASS" "No common shell script security anti-patterns detected"
fi

echo ""
echo "📝 Phase 4: YAML Security Analysis"
echo "=================================="

# Check cloud-init.yaml for security issues
if [ -f "cloud-init.yaml" ]; then
    print_status "INFO" "Analyzing cloud-init.yaml for security issues..."
    
    # Check for hardcoded credentials
    if grep -iqE "(password|secret|key|token).*:" cloud-init.yaml; then
        print_status "WARN" "Potential hardcoded credentials found in cloud-init.yaml"
    else
        print_status "PASS" "No obvious hardcoded credentials in cloud-init.yaml"
    fi
    
    # Check for insecure package installations
    if grep -q "curl.*|.*sh" cloud-init.yaml; then
        print_status "WARN" "cloud-init.yaml: Direct shell execution from curl detected"
    else
        print_status "PASS" "No direct shell execution from remote sources in cloud-init.yaml"
    fi
    
    # Check for unencrypted downloads
    if grep -qE "http://" cloud-init.yaml; then
        print_status "WARN" "cloud-init.yaml: Unencrypted HTTP downloads detected"
    else
        print_status "PASS" "No unencrypted downloads in cloud-init.yaml"
    fi
    
    # Validate YAML syntax
    if python3 -c "import yaml; yaml.safe_load(open('cloud-init.yaml'))" 2>/dev/null; then
        print_status "PASS" "cloud-init.yaml has valid YAML syntax"
    else
        print_status "FAIL" "cloud-init.yaml has invalid YAML syntax"
    fi
else
    print_status "WARN" "cloud-init.yaml not found"
fi

echo ""
echo "🌐 Phase 5: Network Security Analysis"
echo "====================================="

# Parse network security rules from Terraform
print_status "INFO" "Analyzing network security group rules..."
if [ -f "main.tf" ]; then
    # Check for overly permissive SSH access
    if grep -A 10 -B 5 '"SSH"' main.tf | grep -q 'source_address_prefix.*=.*"\*"'; then
        print_status "WARN" "SSH access allows connections from any IP address (0.0.0.0/0)"
        echo "Consider restricting SSH access to specific IP ranges for better security"
    else
        print_status "PASS" "SSH access appears to be properly restricted"
    fi
    
    # Check for overly permissive API access  
    if grep -A 10 -B 5 '"Ollama_API"' main.tf | grep -q 'source_address_prefix.*=.*"\*"'; then
        print_status "WARN" "Ollama API allows connections from any IP address (0.0.0.0/0)"
        echo "Consider using VPN or IP restrictions for API access in production"
    else
        print_status "INFO" "Ollama API access configuration found"
    fi
    
    # Check if NSG rules exist
    if grep -q "azurerm_network_security_group" main.tf; then
        print_status "PASS" "Network Security Group is configured"
    else
        print_status "FAIL" "No Network Security Group found"
    fi
    
    # Check for disk encryption
    if grep -q "disk_encryption_set_id" main.tf; then
        print_status "PASS" "Disk encryption is configured"
    else
        print_status "WARN" "Disk encryption is not explicitly configured"
    fi
else
    print_status "FAIL" "Cannot analyze network security - main.tf not found"
fi

echo ""
echo "🔐 Phase 6: SSH Security Analysis" 
echo "================================="

# Check SSH key configuration
print_status "INFO" "Analyzing SSH key security configuration..."
if grep -q "disable_password_authentication.*=.*true" main.tf; then
    print_status "PASS" "Password authentication is disabled"
else
    print_status "FAIL" "Password authentication is not explicitly disabled"
fi

if grep -q "rsa_bits.*=.*4096" main.tf; then
    print_status "PASS" "SSH key uses 4096-bit RSA (strong)"
else
    print_status "WARN" "SSH key configuration should use 4096-bit RSA for better security"
fi

if grep -q 'file_permission.*=.*"0600"' main.tf; then
    print_status "PASS" "SSH private key has secure file permissions (0600)"
else
    print_status "WARN" "SSH private key permissions should be explicitly set to 0600"
fi

echo ""
echo "📊 Security Test Summary"
echo "======================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"  
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Security testing completed with failures${NC}"
    echo "Please address the failed checks before deployment"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Security testing completed with warnings${NC}"
    echo "Consider addressing warnings for enhanced security"
    exit 0
else
    echo -e "${GREEN}✅ All security tests passed!${NC}"
    echo "Your infrastructure configuration appears secure"
    exit 0
fi