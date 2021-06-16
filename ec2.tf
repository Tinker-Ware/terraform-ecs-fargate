resource "aws_instance" "bastion" {
  ami                         = var.aws_ami_id
  instance_type               = "t3.nano"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = aws_subnet.public_1[0].id
  key_name                    = var.key_pair  

  tags = {
    Name = "DB Bastion"
  }

  depends_on = [aws_security_group.bastion_sg]
}