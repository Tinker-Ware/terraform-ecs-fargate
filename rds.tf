resource "aws_db_instance" "mysql_db" {
  allocated_storage   = 20 # gigabytes, 40 in prod
  engine              = "mysql"
  engine_version      = var.db_version
  identifier          = "${var.cluster_name}-db"
  instance_class      = "db.t2.micro"
  password            = var.db_password
  publicly_accessible = true
  skip_final_snapshot = true
  storage_encrypted   = false
  port                = var.db_port
  username            = var.db_user
}