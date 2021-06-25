provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "InstanceA-ssh-http" {
  name        = "InstanceA-ssh-http"
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


resource "aws_instance" "InstanceA" {
  
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  security_groups        = ["${aws_security_group.InstanceA-ssh-http.name}"]
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
    Name            = "Instance A"
    Contact         = "bv2012"
    Tool            = "Terraform"
    }

}
  

resource "aws_ebs_volume" "data-vol" {
  size              = 1
  type              = "gp3"
  availability_zone = "us-east-1a"
  tags = {
        Name = "data-volume"
 }
}

resource "aws_volume_attachment" "InstanceA-vol" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.data-vol.id}"
 instance_id = "${aws_instance.InstanceA.id}"
}

resource "null_resource" "reboo_instance" {

  provisioner "local-exec" {
    on_failure  = "fail"
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        echo -e "\x1B[31m Warning! Restarting instance having id ${aws_instance.InstanceA.id}.................. \x1B[0m"
        # aws ec2 reboot-instances --instance-ids ${aws_instance.InstanceA.id} --profile test
        # To stop instance
        aws ec2 stop-instances --instance-ids ${aws_instance.InstanceA.id} --profile test
        echo "***************************************Rebooted****************************************************"
     EOT
  }
#   this setting will trigger script every time,change it something needed
  triggers = {
    always_run = "${timestamp()}"
  }


}