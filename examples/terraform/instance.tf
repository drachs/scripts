resource "aws_security_group" "microservice" {
    vpc_id = "${aws_vpc.main.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    // Microservice listens on port 8080
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "ssh-allowed"
    }
}

data "template_file" "user_data" {
  template = file("session-manager.sh")
}

resource "aws_iam_role" "ssm-role" {
  name = "${var.Name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ssm-profile" {
  role = "${aws_iam_role.ssm-role.name}"
  name = "${var.Name}"
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = "${aws_iam_role.ssm-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "microservice" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${aws_subnet.private.id}"
    
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.microservice.id}"]
    
    # the Public SSH key
    key_name = "Dev2"

    // cloud-init
    user_data = data.template_file.user_data.rendered

    iam_instance_profile = "${aws_iam_instance_profile.ssm-profile.name}"
    //iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"

    tags = {
        Name = "${var.Name} - demo"
    }

    depends_on = [aws_nat_gateway.main]

}
