provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "InstanceB-ssh-http" {
  name        = "InstanceB-ssh-http"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "InstanceB" {
  
  ami                    = "ami-08353a25e80beea3e"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  security_groups        = ["${aws_security_group.InstanceB-ssh-http.name}"]
  key_name               = "secure_key_name"
    root_block_device {
    volume_type           = "gp2"
    volume_size           = 9
    delete_on_termination = false
  }

  user_data = <<-EOF
                #! /bin/bash
                sudo  mkdir /dataup
  EOF

  tags = {
    Name            = "Instance B"
    Contact         = "bv2012"
    Tool            = "Terraform"
    }

}
  

resource "aws_ebs_volume" "ebs-vol1" {
  size              = 1
  type              = "gp2"
  availability_zone = "us-east-1a"
  encrypted         = true
  tags = {
        Name = "data-volume"
 }
}

resource "aws_ebs_volume" "ebs-vol2" {
  size              = 1
  type              = "gp2"
  availability_zone = "us-east-1a"
  encrypted         = true
  tags = {
        Name = "data-volume"
 }
}



resource "aws_volume_attachment" "InstanceB-vol1" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.ebs-vol1.id}"
 instance_id = "${aws_instance.InstanceB.id}"
}

resource "aws_volume_attachment" "InstanceB-vol2" {
 device_name = "/dev/sde"
 volume_id = "${aws_ebs_volume.ebs-vol2.id}"
 instance_id = "${aws_instance.InstanceB.id}"
}

resource "null_resource" "reboo_instance" {

  provisioner "local-exec" {
    on_failure  = "fail"
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        echo -e "\x1B[31m Warning! Restarting instance having id ${aws_instance.InstanceB.id}.................. \x1B[0m"
        # aws ec2 reboot-instances --instance-ids ${aws_instance.InstanceB.id} --profile test
        # To stop instance
        aws ec2 stop-instances --instance-ids ${aws_instance.InstanceB.id} --profile test
        echo "***************************************Rebooted****************************************************"
     EOT
  }
#   this setting will trigger script every time,change it something needed
  triggers = {
    always_run = "${timestamp()}"
  }


}