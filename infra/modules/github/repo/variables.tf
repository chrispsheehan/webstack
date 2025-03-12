variable "git_token" {
  description = "Git token used in authentication of github provider"
  type        = string
}

variable "github_repo" {
  description = "Name of a the github repo"
  type        = string
}

variable "default_branch" {
  description = "Name of default branch to be protected and merged into"
  type        = string
}
