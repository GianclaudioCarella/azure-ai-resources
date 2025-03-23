variable "location" {
  type        = string
  description = "Define the region were the Azure resources should be created"
  default     = "North Europe"
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "DEV"
}