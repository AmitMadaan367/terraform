resource "aws_vpc" "dev" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_internet_gateway" "myInternetGateway" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Dev-publicSubnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Dev-PrivateSubnet"
  }
}


resource "aws_eip" "nat_eip"{
  vpc=true
}

resource "aws_nat_gateway" "myNatGateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.public.id
  tags = {
    Name = "myNatGateway"
  }

}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myInternetGateway.id
  }
  
  
  tags = {
    Name = "publicRouteTable"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNatGateway.id
  }


  tags = {
    Name = "privateRouteTable"
  }
}

resource "aws_route_table_association" "forPublic" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "forPrivate" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "public" {
  name = "my-public-sg"
  description = "Public internet access"
  vpc_id = aws_vpc.dev.id
 
  tags = {
    Name        = "my-public-sg"
    Role        = "public"
    Project     = "cloudcasts.io"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}



resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}




resource "aws_instance" "PublicMachine" {
  ami           = "ami-09d56f8956ab235b3"
  instance_type = "t2.micro"
  key_name               = "webApp"
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id              = aws_subnet.public.id
  associate_public_ip_address = "true"


  tags = {
    Name = "pub"
    Terraform   = "true"
    Environment = "public"
  }

}

resource "aws_instance" "PrivateMachine" {

  ami           = "ami-09d56f8956ab235b3"
  instance_type = "t2.micro"
  key_name               = "webApp"
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id              = aws_subnet.private.id


  tags = {
    Terraform   = "private"
    Environment = "private"
    Name = "pri"
  }

}