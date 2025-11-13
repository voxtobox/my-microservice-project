variable "name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "5.46.4"
}

variable "app_repo_url" {
  description = "Repository URL for Argo CD application"
  type        = string
}

variable "app_repo_username" {
  description = "Username for Argo CD repository access"
  type        = string
}

variable "app_repo_password" {
  description = "Password or token for Argo CD repository access"
  type        = string
  sensitive   = true
}

