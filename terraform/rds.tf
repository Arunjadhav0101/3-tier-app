resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.2"
  availability_zones      = data.aws_availability_zones.available.names
  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = 2
  identifier         = "${var.project_name}-aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}
