variable "name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.8.27"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "service_account_name" {
  description = "Service account used by Jenkins controller"
  type        = string
  default     = "jenkins-sa"
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  type        = string
}

variable "github_username" {
  description = "GitHub username for Jenkins credentials"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Jenkins"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "Git repository URL containing Jenkins seed job pipeline"
  type        = string
}

