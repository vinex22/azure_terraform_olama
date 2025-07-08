#!/bin/bash

# Security Testing Demo Script
# Author: Vinay Jain (https://github.com/vinex22)
# Repository: https://github.com/vinex22/azure_terraform_olama
#
# This script demonstrates how to test security without running the actual code

echo "🔒 Azure Terraform Ollama - Security Testing Demo"
echo "=================================================="
echo ""
echo "This demo shows how to test your infrastructure security"
echo "WITHOUT deploying any actual Azure resources!"
echo ""

# Function to wait for user input
wait_for_user() {
    echo ""
    read -p "Press Enter to continue..." -r
    echo ""
}

echo "📋 What we'll demonstrate:"
echo "1. Quick security validation (5 seconds)"
echo "2. Advanced security analysis with Python"
echo "3. Terraform security scanning with tfsec"
echo "4. Shell script security validation"
echo "5. Security recommendations and best practices"

wait_for_user

echo "🚀 Demo 1: Quick Security Check"
echo "==============================="
echo "Running ./quick-security-check.sh..."
echo ""
./quick-security-check.sh

wait_for_user

echo "🔬 Demo 2: Advanced Security Analysis"
echo "====================================="
echo "Running python3 security-analysis.py..."
echo ""
python3 security-analysis.py

wait_for_user

echo "🛡️ Demo 3: Terraform Security Scanning"
echo "======================================"
echo "Running tfsec via Docker..."
echo ""
docker run --rm -v "$(pwd)":/src aquasec/tfsec:latest /src --no-color --format compact | head -n 10
echo ""
echo "(Output truncated for demo - run 'make security-tfsec' for full results)"

wait_for_user

echo "🐚 Demo 4: Shell Script Security Analysis"
echo "========================================="
echo "Running ShellCheck on all scripts..."
echo ""
make security-shellcheck | head -n 20
echo ""
echo "(Output truncated for demo - run 'make security-shellcheck' for full results)"

wait_for_user

echo "📊 Summary: Available Security Testing Commands"
echo "==============================================="
echo ""
echo "Fast Development Testing:"
echo "  ./quick-security-check.sh       # 5-second security check"
echo "  make security-quick              # Same as above"
echo ""
echo "Comprehensive Testing:"
echo "  ./security-test.sh               # Full security suite (2-3 minutes)"
echo "  make security-all                # All security tests"
echo ""
echo "Individual Tools:"
echo "  python3 security-analysis.py    # Advanced Python analysis"
echo "  make security-tfsec              # Terraform security scanning"
echo "  make security-checkov            # Policy validation"
echo "  make security-shellcheck         # Shell script analysis"
echo ""
echo "📚 Documentation:"
echo "  README.md                        # Basic security information"
echo "  SECURITY_TESTING.md             # Complete security testing guide"
echo ""
echo "🔄 CI/CD Integration:"
echo "  GitHub Actions automatically runs security tests on every push/PR"
echo "  Check the .github/workflows/terraform.yml file"
echo ""
echo "✅ Benefits:"
echo "  • Identify security issues before deployment"
echo "  • No Azure costs for security testing"
echo "  • Fast feedback during development"
echo "  • Comprehensive coverage of Terraform, YAML, and shell scripts"
echo "  • Integration with popular security tools (tfsec, checkov, shellcheck)"
echo ""
echo "🎯 Next Steps:"
echo "  1. Run 'make security-quick' during development"
echo "  2. Run 'make security-all' before commits"
echo "  3. Address any HIGH or CRITICAL security issues"
echo "  4. Review and consider fixing MEDIUM warnings"
echo "  5. Deploy with confidence!"
echo ""
echo "Demo completed! 🎉"