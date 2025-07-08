# Azure Terraform Ollama - Variable Definitions
# Author: Vinay Jain (https://github.com/vinex22)
# Repository: https://github.com/vinex22/azure_terraform_olama

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East Asia"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D4s_v3"
}
