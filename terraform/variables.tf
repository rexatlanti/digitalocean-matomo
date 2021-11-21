variable "db_version" {
  default     = "8"
  type        = string
  description = "DO MySQL version to use"
}

variable "db_size" {
  default     = "db-s-1vcpu-1gb"
  type        = string
  description = "Size of MySQL image"
}

variable "do_region" {
  default     = "nyc1"
  type        = string
  description = "Region to locate all services in"
}

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