resource "aws_instance" "us-east-2" {
  ami           = "ami-0aeb7c931a5a61206"
  instance_type = "t2.micro"
  provider = aws.useast2
}