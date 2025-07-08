# Ollama VM Access Script for Windows PowerShell
# Author: Vinay Jain (https://github.com/vinex22)
# Repository: https://github.com/vinex22/azure_terraform_olama
# This script provides easy access to your Ollama VM through SSH tunnel

param(
    [string]$Action = "tunnel",
    [string]$Prompt = "Hello, how are you?"
)

# Get VM IP from terraform output
$VM_IP = (terraform output -raw vm_public_ip)
$SSH_KEY = "ssh_keys/ollama_vm_key"

function Show-Usage {
    Write-Host "Ollama VM Access Script"
    Write-Host "Usage: .\ollama-access.ps1 [action] [prompt]"
    Write-Host ""
    Write-Host "Actions:"
    Write-Host "  tunnel    - Start SSH tunnel (default)"
    Write-Host "  test      - Test API through tunnel"
    Write-Host "  chat      - Chat with model through tunnel"
    Write-Host "  ssh       - SSH into VM"
    Write-Host "  status    - Check VM status"
    Write-Host "  logs      - View cloud-init logs"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\ollama-access.ps1 tunnel"
    Write-Host "  .\ollama-access.ps1 test"
    Write-Host "  .\ollama-access.ps1 chat 'Tell me about AI'"
    Write-Host "  .\ollama-access.ps1 ssh"
}

function Start-SSHTunnel {
    Write-Host "Starting SSH tunnel to $VM_IP..."
    Write-Host "After tunnel is established, you can access Ollama at: http://localhost:11434"
    Write-Host "Press Ctrl+C to stop the tunnel"
    Write-Host ""
    
    # Start SSH tunnel
    ssh -i $SSH_KEY -L 11434:localhost:11434 -N azureuser@$VM_IP
}

function Test-API {
    Write-Host "Testing Ollama API through SSH tunnel..."
    
    # Check if tunnel is active by testing the API
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/version" -Method Get -TimeoutSec 5
        Write-Host "✓ API Version: $($response.version)" -ForegroundColor Green
        
        # Test model list
        $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get
        Write-Host "✓ Available models:" -ForegroundColor Green
        foreach ($model in $models.models) {
            Write-Host "  - $($model.name) ($($model.size))" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "✗ API not accessible. Make sure SSH tunnel is running!" -ForegroundColor Red
        Write-Host "Run: .\ollama-access.ps1 tunnel" -ForegroundColor Yellow
    }
}

function Chat-WithModel {
    param($UserPrompt)
    
    Write-Host "Chatting with llama3.2:3b..." -ForegroundColor Cyan
    Write-Host "Prompt: $UserPrompt" -ForegroundColor Gray
    Write-Host ""
    
    try {
        $body = @{
            model = "llama3.2:3b"
            prompt = $UserPrompt
            stream = $false
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json"
        
        Write-Host "Response:" -ForegroundColor Green
        Write-Host $response.response -ForegroundColor White
        Write-Host ""
        Write-Host "Stats: Generated $($response.eval_count) tokens in $([math]::Round($response.total_duration / 1000000000, 2)) seconds" -ForegroundColor Gray
    }
    catch {
        Write-Host "✗ Failed to chat with model. Make sure SSH tunnel is running!" -ForegroundColor Red
        Write-Host "Run: .\ollama-access.ps1 tunnel" -ForegroundColor Yellow
    }
}

function SSH-Connect {
    Write-Host "Connecting to VM via SSH..."
    ssh -i $SSH_KEY azureuser@$VM_IP
}

function Check-Status {
    Write-Host "Checking VM status..."
    Write-Host "VM IP: $VM_IP"
    Write-Host ""
    
    # Test SSH connection
    Write-Host "Testing SSH connection..." -NoNewline
    $sshTest = ssh -i $SSH_KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no azureuser@$VM_IP "echo 'OK'" 2>$null
    if ($sshTest -eq "OK") {
        Write-Host " ✓" -ForegroundColor Green
    } else {
        Write-Host " ✗" -ForegroundColor Red
        return
    }
    
    # Check Ollama service
    Write-Host "Checking Ollama service..." -NoNewline
    $ollamaStatus = ssh -i $SSH_KEY azureuser@$VM_IP "systemctl is-active ollama" 2>$null
    if ($ollamaStatus -eq "active") {
        Write-Host " ✓" -ForegroundColor Green
    } else {
        Write-Host " ✗ ($ollamaStatus)" -ForegroundColor Red
    }
    
    # Check model availability
    Write-Host "Checking model availability..." -NoNewline
    $modelCheck = ssh -i $SSH_KEY azureuser@$VM_IP "ollama list | grep llama3.2:3b" 2>$null
    if ($modelCheck) {
        Write-Host " ✓" -ForegroundColor Green
    } else {
        Write-Host " ✗" -ForegroundColor Red
    }
}

function View-Logs {
    Write-Host "Viewing cloud-init logs from VM..."
    ssh -i $SSH_KEY azureuser@$VM_IP "sudo tail -50 /var/log/cloud-init-output.log"
}

# Main script logic
switch ($Action.ToLower()) {
    "tunnel" { Start-SSHTunnel }
    "test" { Test-API }
    "chat" { Chat-WithModel $Prompt }
    "ssh" { SSH-Connect }
    "status" { Check-Status }
    "logs" { View-Logs }
    "help" { Show-Usage }
    default { Show-Usage }
}
