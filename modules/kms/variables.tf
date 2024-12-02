variable "counter" {
  description = "Current counter"
  type        = number
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
