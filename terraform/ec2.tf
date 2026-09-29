data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

locals {
  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo "${var.jenkins_pubkey}" >> /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              chmod 700 /home/ubuntu/.ssh
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              EOF
}

resource "aws_instance" "k8s_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.master_instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  credit_specification {
    cpu_credits = "unlimited"   # avoids CPU throttling on burstable t3
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = { Name = "k8s-master", Role = "kubernetes-master" }
}

resource "aws_instance" "k8s_worker" {
  count                       = var.worker_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.worker_instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  user_data                   = local.user_data

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = { Name = "k8s-worker-${count.index + 1}", Role = "kubernetes-worker" }
}
