resource "aws_dms_endpoint" "mydbsrc" {
  endpoint_id                 = "mydbsrc"
  endpoint_type               = "source"
  engine_name                 = "mysql"
  username                    = "root"
  server_name                 = aws_db_instance.src_old.address
  port                        = 3306
  password                    = var.db_root_passwd
}

resource "aws_dms_endpoint" "mydbdst" {
  endpoint_id                 = "mydbdst"
  endpoint_type               = "target"
  engine_name                 = "mysql"
  username                    = "root"
  server_name                 = aws_db_instance.dst_new.address
  port                        = 3306
  password                    = var.db_root_passwd
}
