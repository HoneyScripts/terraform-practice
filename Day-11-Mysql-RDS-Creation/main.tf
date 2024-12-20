resource "aws_db_instance" "my_rds" {
  identifier           = "my-db-instance"
  allocated_storage    = 20
  instance_class       = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  db_name              = "database"
  username             = "Honey"
  password             = "Honey123"
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}

resource "aws_security_group" "rds_sg" {
  name = "rds-security-group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = ["subnet-01682e9378145cc9e","subnet-0cacf8f994f1e734d"]
}

resource "null_resource" "db_initializer" {
  depends_on = [aws_db_instance.my_rds]

  provisioner "local-exec" {
    command = <<EOT
mysql -h ${aws_db_instance.my_rds.address} \
      -u Honey \
      -pHoney123 \
      -e "source ./initialize_db.sql"
EOT
  }

  triggers = {
    db_instance_id = aws_db_instance.my_rds.id
  }
}