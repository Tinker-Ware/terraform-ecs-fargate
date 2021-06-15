resource "aws_db_instance" "mysql_db" {
  allocated_storage   = 40 # gigabytes
  snapshot_identifier = var.db_snapshot_identifier
  engine              = "mysql"
  engine_version      = var.db_version
  identifier          = "${var.cluster_name}-db"
  instance_class      = "db.t2.micro"
  password            = var.db_password
  skip_final_snapshot = true
  storage_encrypted   = false
  port                = var.db_port
  username            = var.db_user

  vpc_security_group_ids  = [ aws_security_group.ecs_sg.id, aws_security_group.ecs_private_sg.id ]
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.public_subnet_group.name
}