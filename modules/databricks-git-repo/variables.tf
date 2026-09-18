variable "url" {
  description = "URL of the Git repository to clone as a workspace Git Folder."
  type        = string
}

variable "path" {
  description = "Workspace path for the Git Folder. Required (no default) -- the provider's computed default resolves to a personal folder under the deploying identity, which is not what this module is for."
  type        = string
}
