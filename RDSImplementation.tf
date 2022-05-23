resource "aws_db_instance" "projectDB" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "myTerraformDb"
  username             = "root"
  password             = "User#123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
