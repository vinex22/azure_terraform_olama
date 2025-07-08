# Makefile for Azure Terraform Ollama Security Testing
# Author: Vinay Jain (https://github.com/vinex22)

.PHONY: help security-quick security-full security-advanced security-tfsec security-checkov security-shellcheck clean

# Default target
help:
	@echo "🔒 Azure Terraform Ollama - Security Testing"
	@echo "============================================"
	@echo ""
	@echo "Available targets:"
	@echo "  security-quick     - Quick security validation (recommended for development)"
	@echo "  security-full      - Comprehensive security testing suite"
	@echo "  security-advanced  - Advanced Python-based security analysis"
	@echo "  security-tfsec     - Run tfsec Terraform security scanner"
	@echo "  security-checkov   - Run Checkov policy scanner"
	@echo "  security-shellcheck - Run ShellCheck on shell scripts"
	@echo "  security-all       - Run all security tests"
	@echo "  clean             - Clean up temporary files"
	@echo ""
	@echo "Examples:"
	@echo "  make security-quick     # Fast development check"
	@echo "  make security-full      # Complete security analysis"
	@echo "  make security-all       # Run everything"

# Quick security check (development)
security-quick:
	@echo "🚀 Running quick security validation..."
	@chmod +x quick-security-check.sh
	@./quick-security-check.sh

# Comprehensive security testing
security-full:
	@echo "🔍 Running comprehensive security testing..."
	@chmod +x security-test.sh
	@./security-test.sh

# Advanced security analysis
security-advanced:
	@echo "🔬 Running advanced security analysis..."
	@python3 security-analysis.py

# Run tfsec security scanner
security-tfsec:
	@echo "🛡️ Running tfsec security scanner..."
	@docker run --rm -v $$(pwd):/src aquasec/tfsec:latest /src

# Run Checkov policy scanner
security-checkov:
	@echo "📋 Running Checkov policy scanner..."
	@docker run --rm -v $$(pwd):/tf bridgecrew/checkov -f /tf/main.tf --framework terraform

# Run ShellCheck on shell scripts
security-shellcheck:
	@echo "🐚 Running ShellCheck on shell scripts..."
	@for script in *.sh; do \
		if [ -f "$$script" ]; then \
			echo "Checking $$script..."; \
			shellcheck "$$script" || echo "Issues found in $$script"; \
		fi \
	done

# Run all security tests
security-all: security-quick security-advanced security-tfsec security-checkov security-shellcheck
	@echo ""
	@echo "✅ All security tests completed!"

# Clean up temporary files
clean:
	@echo "🧹 Cleaning up temporary files..."
	@rm -f *.tmp *.log
	@rm -rf .terraform/
	@echo "Clean up completed!"

# Install dependencies (Ubuntu/Debian)
install-deps:
	@echo "📦 Installing security testing dependencies..."
	@sudo apt-get update
	@sudo apt-get install -y shellcheck python3 python3-pip docker.io
	@pip3 install PyYAML
	@echo "Dependencies installed!"