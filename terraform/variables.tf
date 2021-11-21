variable "use_dns" {
  default     = false
  type        = bool
  description = "Toggle for creating an A record, or not."
}

variable "ssh_key" {
  type        = string
  description = "Public SSH key, used to connect to the DO Droplet"
  sensitive   = true
}