resource "aws_vpc" "mainVPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
      key = "Name"
      value = "${var.namePrefix}-vpc-webServer-ECS"
  }
}

resource "aws_internet_gateway" "internetGW" {
  vpc_id = "${aws_vpc.mainVPC.id}"


}

resource "aws_route_table" "routeTable" {
  vpc_id = "${aws_vpc.mainVPC.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.internetGW.id}"
  }
}

resource "aws_main_route_table_association" "routeTableAsc" {
  vpc_id = "${aws_vpc.mainVPC.id}"
  route_table_id = "${aws_route_table.routeTable.id}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcpAsc" {
  vpc_id = "${aws_vpc.mainVPC.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}


# Subnets

# resource "aws_subnet" "subnet" {
#   count = 1
#   vpc_id = "${aws_vpc.mainVPC.id}"
#   cidr_block = "10.0.${count.index}.0/24"
#   map_public_ip_on_launch = true
#   availability_zone = "${var.awsRegion}${element(split(",", var.subnetAZs), count.index)}"
#   tags = {
#     key = "Name"
#     value = "${var.namePrefix}-webServer-subnet"
#   }
# }

resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.mainVPC.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  tags = {
    key = "Name"
    value = "${var.namePrefix}-webServer-subnet"
  }
}

# Security group for Application Load Balancer allowing access from this only

resource "aws_security_group" "sgAlb" {
  name = "${var.namePrefix}-alb-sg"
  vpc_id = "${aws_vpc.mainVPC.id}"
  description = "Security group for ALBs"

  ingress {
      from_port = 80
      to_port = 80 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 8080
      to_port = 8080 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      key = "Name"
      value = "${var.namePrefix}-alb-sg"
  }
}

# Security group for ec2 instance

resource "aws_security_group" "sgec2" {
  name = "${var.namePrefix}-ec2-sg"
  vpc_id = "${aws_vpc.mainVPC.id}"
  description = "Security group for ec2"

  ingress {
      from_port = 80
      to_port = 80 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 8080
      to_port = 8080 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      key = "Name"
      value = "${var.namePrefix}-ec2-sg"
  }
}

# Security group for ECS instances
resource "aws_security_group" "sgECS" {
  name = "${var.namePrefix}-ecs-sg"
  vpc_id = "${aws_vpc.mainVPC.id}"
  description = "Security group for ECS Instances"

  tags = {
      key = "Name"
      value = "${var.namePrefix}-ecs-sg"
  }
}

resource "aws_security_group_rule" "outboundAllECS" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sgECS.id}"
  #source_security_group_id = "${aws_security_group.sgAlb.id}"
}

resource "aws_security_group_rule" "inboundECS-ALB" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.sgECS.id}"
  source_security_group_id = "${aws_security_group.sgAlb.id}"
}

resource "aws_security_group_rule" "allow_all_from_peers" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.sgECS.id}"
    source_security_group_id = "${aws_security_group.sgECS.id}"
}

resource "aws_security_group_rule" "inboundAllSSH" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sgECS.id}"
}
