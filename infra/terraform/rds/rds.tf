resource "aws_db_parameter_group" "src_old" {
  name   = "rds-pg-mysql56"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_checksum"
    value = "NONE"
  }

  parameter {
    name  = "binlog_row_image"
    value = "FULL"
  }
}

resource "aws_db_parameter_group" "dst_new" {
  name   = "rds-pg-mysql57"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [ module.vpc.subnet_private1_id, module.vpc.subnet_private2_id ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-security-group"
  description = "allow inbound access to the database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    // protocol    = "tcp"
    // from_port   = 0
    // to_port     = 3306
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ module.vpc.vpc_cidr ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ module.vpc.vpc_cidr ]
  }
}

resource "aws_db_instance" "src_old" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "db.t2.micro"
  identifier           = "mydbsrc"
  name                 = "mydbsrc"
  username             = "root"
  backup_retention_period = 3
  password             = var.db_root_passwd
  parameter_group_name = aws_db_parameter_group.src_old.id
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az             = false
}

resource "aws_db_instance" "dst_new" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "mydbdst"
  name                 = "mydbdst"
  username             = "root"
  password             = var.db_root_passwd
  parameter_group_name = aws_db_parameter_group.dst_new.id
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az             = false
}