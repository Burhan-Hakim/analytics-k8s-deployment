variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "jenkins_pubkey" {
  description = "Contents of ~/.ssh/id_rsa.pub on jenkins-master"
  type        = string
  sensitive   = true
}

variable "master_instance_type" {
  type    = string
  default = "t3.large"
}

variable "worker_instance_type" {
  type    = string
  default = "t3.small"
}

variable "worker_count" {
  type    = number
  default = 2
}
