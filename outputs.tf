output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.ollama_rg.name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.ollama_public_ip.ip_address
}

output "vm_fqdn" {
  description = "Fully qualified domain name of the VM"
  value       = azurerm_public_ip.ollama_public_ip.fqdn
}

output "ssh_connection_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ssh_keys/ollama_vm_key azureuser@${azurerm_public_ip.ollama_public_ip.ip_address}"
}

output "ollama_api_url" {
  description = "URL for Ollama API"
  value       = "http://${azurerm_public_ip.ollama_public_ip.ip_address}:11434"
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = "${path.module}/ssh_keys/ollama_vm_key"
}

output "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  value       = "${path.module}/ssh_keys/ollama_vm_key.pub"
}
