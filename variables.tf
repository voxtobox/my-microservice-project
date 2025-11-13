variable "github_username" {
  description = "GitHub username used by Jenkins and Argo CD"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Jenkins"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "Repository URL Jenkins seed job pulls from"
  type        = string
}

variable "app_repo_url" {
  description = "Repository URL for Argo CD application"
  type        = string
}

variable "app_repo_username" {
  description = "Username for accessing Argo CD application repository"
  type        = string
}

variable "app_repo_password" {
  description = "Password or token for Argo CD application repository"
  type        = string
  sensitive   = true
}

