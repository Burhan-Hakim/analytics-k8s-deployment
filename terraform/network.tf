data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# All nodes in one subnet/AZ so kubeadm nodes reach each other directly
data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}
