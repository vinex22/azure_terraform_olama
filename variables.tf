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

variable "ollama_model" {
  description = "Ollama model to pre-download"
  type        = string
  default     = "llama3.2:3b"
}
