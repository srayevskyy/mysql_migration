resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.dev_key.public_key_openssh
}

resource "aws_iam_role" "test_role_rds" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "my_iam_policy" {
  name = "my_iam_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "rds-db:connect",
        Effect   = "Allow"
        Resource = "arn:aws:rds-db:*:${data.aws_caller_identity.current.account_id}:dbuser:*/*"
      },
    ]
  })
}

resource "aws_iam_role" "my_iam_role_ec2" {
  name                = "my_iam_role_ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [ aws_iam_policy.my_iam_policy.arn ]
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.my_iam_role_ec2.name}"
}

resource "null_resource" "example1" {
  provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./'${var.generated_key_name}'.pem
      chmod 400 ./'${var.generated_key_name}'.pem
    EOT
  }

  provisioner "local-exec" {    # Generate ssh_into_ec2.sh in current directory
    command = <<-EOT
      echo 'ssh -i terraform-key-pair.pem ubuntu@${aws_instance.public-ec2.public_dns}' > ./ssh_into_ec2.sh
      chmod +x ssh_into_ec2.sh
      EOT
  }

  depends_on = [ tls_private_key.dev_key, aws_key_pair.generated_key ]
}

resource "aws_instance" "public-ec2" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = module.vpc.subnet_public_id
    key_name      = var.generated_key_name
    vpc_security_group_ids = [ aws_security_group.ec2-sg.id ]
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

    tags = {
        Name = "ec2-main"
    }

    depends_on = [ 
      module.vpc.vpc_id, 
      module.vpc.igw_id, 
      aws_db_instance.src_old, 
      aws_db_instance.dst_new,
      aws_dms_replication_instance.src-to-dest, 
    ]

    user_data = <<EOF
#!/bin/sh
set -x
sudo apt-get update
sudo apt-get install -y mysql-client
echo ${aws_db_instance.src_old.address} >/tmp/dbdomain.txt
sudo mv /tmp/dbdomain.txt /dbdomain.txt

# Jenkins install
sudo apt update
sudo apt install -y ca-certificates openjdk-8-jdk mc
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/lib/jenkins/config.xml

# Docker install
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

# Tools install
sudo apt-get install -y mariadb-client libmariadbclient18 awscli

# env variable setup
echo "MYSQL_SRC_HOST='${aws_db_instance.src_old.address}'" | sudo tee -a /etc/environment
echo "MYSQL_DST_HOST='${aws_db_instance.dst_new.address}'" | sudo tee -a /etc/environment
echo "SOURCE_ENDPOINT_ARN='${aws_dms_endpoint.mydbsrc.endpoint_arn}'" | sudo tee -a /etc/environment
echo "TARGET_ENDPOINT_ARN='${aws_dms_endpoint.mydbdst.endpoint_arn}'" | sudo tee -a /etc/environment
echo "REPLICATION_INSTANCE_ARN='${aws_dms_replication_instance.src-to-dest.replication_instance_arn}'" | sudo tee -a /etc/environment

# restart Jenkins
sudo service jenkins restart

# create iam user in target mysql
mysql -vvv -h ${aws_db_instance.dst_new.address} -P 3306 -u root -p${var.db_root_passwd} -e "CREATE DATABASE IF NOT EXISTS dms_sample"
mysql -vvv -h ${aws_db_instance.dst_new.address} -P 3306 -u root -p${var.db_root_passwd} -e "CREATE USER IF NOT EXISTS iam_admin IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS'"
mysql -vvv -h ${aws_db_instance.dst_new.address} -P 3306 -u root -p${var.db_root_passwd} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON dms_sample.* TO 'iam_admin'@'%' REQUIRE SSL"

EOF
}

resource "aws_security_group" "ec2-sg" {
  name        = "security-group"
  description = "allow inbound access to the EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
