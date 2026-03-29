variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "java-eks-cluster"
}

variable "node_instance_type" {
  default = "c7i-flex.large"
}

variable "desired_size" {
  default = 1
}
