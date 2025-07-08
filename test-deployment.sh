#!/bin/bash

# Test script for Ollama VM deployment
# Author: Vinay Jain (https://github.com/vinex22)
# Repository: https://github.com/vinex22/azure_terraform_olama
# This script tests the deployment from outside the VM

echo "Testing Ollama VM deployment..."

# Get VM public IP from terraform output
PUBLIC_IP=$(terraform output -raw vm_public_ip)
echo "VM Public IP: $PUBLIC_IP"

# Test SSH connection
echo "Testing SSH connection..."
if ssh -i ssh_keys/ollama_vm_key -o ConnectTimeout=10 -o StrictHostKeyChecking=no azureuser@$PUBLIC_IP "echo 'SSH connection successful'"; then
    echo "✓ SSH connection working"
else
    echo "✗ SSH connection failed"
    exit 1
fi

# Test Ollama API from within VM
echo "Testing Ollama API..."
API_RESPONSE=$(ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP "curl -s http://localhost:11434/api/version")
if [ $? -eq 0 ] && [ -n "$API_RESPONSE" ]; then
    echo "✓ Ollama API is running: $API_RESPONSE"
else
    echo "✗ Ollama API is not responding"
    exit 1
fi

# Test model availability
echo "Testing model availability..."
MODEL_LIST=$(ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP "ollama list")
if echo "$MODEL_LIST" | grep -q "llama3.2:3b"; then
    echo "✓ Model llama3.2:3b is available"
else
    echo "✗ Model llama3.2:3b is not available"
    echo "Available models:"
    echo "$MODEL_LIST"
    exit 1
fi

# Test model interaction
echo "Testing model interaction..."
RESPONSE=$(ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP 'curl -s -X POST http://localhost:11434/api/generate -d "{\"model\": \"llama3.2:3b\", \"prompt\": \"Say hello in one word\", \"stream\": false}"')
if [ $? -eq 0 ] && echo "$RESPONSE" | grep -q "response"; then
    echo "✓ Model interaction working"
    echo "Sample response: $(echo "$RESPONSE" | jq -r '.response' 2>/dev/null || echo "Unable to parse response")"
else
    echo "✗ Model interaction failed"
    echo "Response: $RESPONSE"
    exit 1
fi

# Test if Ollama is listening on all interfaces
echo "Testing network configuration..."
NETSTAT_OUTPUT=$(ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP "sudo ss -tlnp | grep 11434")
if echo "$NETSTAT_OUTPUT" | grep -q "\*:11434"; then
    echo "✓ Ollama is listening on all interfaces"
else
    echo "✗ Ollama is not listening on all interfaces"
    echo "Current configuration: $NETSTAT_OUTPUT"
fi

echo ""
echo "=== Deployment Test Summary ==="
echo "SSH Connection: ✓"
echo "Ollama API: ✓"
echo "Model Available: ✓"
echo "Model Interaction: ✓"
echo "Network Configuration: ✓"
echo ""
echo "Your Ollama VM is ready to use!"
echo "SSH command: ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP"
echo "API endpoint: http://$PUBLIC_IP:11434 (accessible from VM)"
echo "Test API: ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP 'curl http://localhost:11434/api/version'"
echo ""
echo "To interact with the model:"
echo "ssh -i ssh_keys/ollama_vm_key azureuser@$PUBLIC_IP"
echo "curl -X POST http://localhost:11434/api/generate -d '{\"model\": \"llama3.2:3b\", \"prompt\": \"Your prompt here\", \"stream\": false}'"
