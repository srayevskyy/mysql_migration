resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.dev_key.public_key_openssh
}

resource "aws_iam_policy" "my_iam_policy" {
  name = "my_iam_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
          "Effect": "Allow",
          "Action": [ "rds-db:connect" ],
          "Resource": [ "arn:aws:rds-db:us-west-2:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.dst_new.resource_id}/iam_admin" ]
      },
      {
          "Effect": "Allow",
          "Action": [ "rds-db:connect" ],
          "Resource": [ "arn:aws:rds-db:us-west-2:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.src_old.resource_id}/iam_admin" ]
      },
      {
          "Effect": "Allow",
          "Action": [
            "dms:DescribeReplicationTasks",
            "dms:DescribeEndpoints",
            "dms:DescribeReplicationInstances",
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "dms:ModifyReplicationTask",
              "dms:StartReplicationTask",
              "dms:StopReplicationTask"
          ],
          "Resource": [
              "${aws_dms_replication_task.src_to_dest_terraform.replication_task_arn}"
          ]
      }
    ]
  })

  tags = {}
}

resource "aws_iam_role" "my_iam_role_ec2" {
  name = "my_iam_role_ec2"

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

resource "aws_iam_instance_profile" "my_iam_instance_profile" {
  name = "my_iam_instance_profile"
  role = "${aws_iam_role.my_iam_role_ec2.name}"
}

resource "null_resource" "pem_file_generator" {
  provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./'${var.generated_key_name}'.pem
      chmod 400 ./'${var.generated_key_name}'.pem
    EOT
  }

  depends_on = [ tls_private_key.dev_key ]
}

resource "null_resource" "ssh_into_ec2_generator" {
  provisioner "local-exec" {    # Generate ssh_into_ec2.sh in current directory
    command = <<-EOT
      echo 'ssh -i terraform-key-pair.pem ubuntu@${aws_instance.public-ec2.public_dns}' > ./ssh_into_ec2.sh
      chmod +x ssh_into_ec2.sh
      EOT
  }

  # TODO: Look at https://www.terraform.io/docs/language/resources/provisioners/file.html#directory-uploads

  # provisioner "file" {
  #   source      = "jenkins_init/4_plugins.groovy"
  #   destination = "/var/lib/jenkins/init.groovy.d/4_plugins.groovy"

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = "${file("terraform-key-pair.pem")}"
  #     host        = "${aws_instance.public-ec2.public_dns}"
  #   }
  # }  

  depends_on = [ aws_instance.public-ec2, null_resource.pem_file_generator ]
}

resource "aws_instance" "public-ec2" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = module.vpc.subnet_public_id
    key_name      = var.generated_key_name
    vpc_security_group_ids = [ aws_security_group.ec2-sg.id ]
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.my_iam_instance_profile.name}"

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

# env variable setup
echo "MYSQL_SRC_HOST='${aws_db_instance.src_old.address}'" | sudo tee -a /etc/environment
echo "MYSQL_DST_HOST='${aws_db_instance.dst_new.address}'" | sudo tee -a /etc/environment
echo "SOURCE_ENDPOINT_ARN='${aws_dms_endpoint.mydbsrc.endpoint_arn}'" | sudo tee -a /etc/environment
echo "TARGET_ENDPOINT_ARN='${aws_dms_endpoint.mydbdst.endpoint_arn}'" | sudo tee -a /etc/environment
echo "REPLICATION_INSTANCE_ARN='${aws_dms_replication_instance.src-to-dest.replication_instance_arn}'" | sudo tee -a /etc/environment

# Jenkins install
sudo apt update
sudo apt install -y ca-certificates openjdk-8-jdk mc
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins

mkdir -p ${var.JENKINS_HOME}/init.groovy.d

sudo tee -a ${var.JENKINS_HOME}/init.groovy.d/1_jenkins_setup_completed.groovy << END1
#!groovy

import jenkins.model.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
END1

sudo tee -a ${var.JENKINS_HOME}/init.groovy.d/2_disable_csrf.groovy << END2
import jenkins.model.Jenkins
def instance = Jenkins.instance
instance.setCrumbIssuer(null)
END2

sudo tee -a ${var.JENKINS_HOME}/init.groovy.d/3_extra_logging.groovy << END3
import java.util.logging.ConsoleHandler
import java.util.logging.FileHandler
import java.util.logging.SimpleFormatter
import java.util.logging.LogManager
import jenkins.model.Jenkins

def logsDir = new File(Jenkins.instance.rootDir, "logs")

if(!logsDir.exists()){
    println "--> creating log dir";
    logsDir.mkdirs();
}

def loggerWinstone = LogManager.getLogManager().getLogger("");
FileHandler handlerWinstone = new FileHandler(logsDir.absolutePath + "/jenkins-winstone.log", 1024 * 1024, 10, true);

handlerWinstone.setFormatter(new SimpleFormatter());
loggerWinstone.addHandler (new ConsoleHandler());
loggerWinstone.addHandler(handlerWinstone);
END3

sudo tee -a ${var.JENKINS_HOME}/init.groovy.d/4_admin_password.groovy << END4
/*
 * Create an admin user.
 */
import jenkins.model.*
import hudson.security.*

println "--> creating admin user"

//def adminUsername = System.getenv("ADMIN_USERNAME")
//def adminPassword = System.getenv("ADMIN_PASSWORD")

def adminUsername = "admin"
def adminPassword = "${var.jenkins_admin_password}"

assert adminPassword != null : "No ADMIN_USERNAME env var provided, but required"
assert adminPassword != null : "No ADMIN_PASSWORD env var provided, but required"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(strategy)

Jenkins.instance.save()
END4

sudo tee -a ${var.JENKINS_HOME}/init.groovy.d/5_plugins.groovy << END5
import jenkins.*
import hudson.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*;
import hudson.model.*
import jenkins.model.*
import hudson.security.*

final List<String> REQUIRED_PLUGINS = [
        "workflow-aggregator",
        "git",
        "ws-cleanup",
]

if (Jenkins.instance.pluginManager.plugins.collect {
  it.shortName
}.intersect(REQUIRED_PLUGINS).size() != REQUIRED_PLUGINS.size()) {
  REQUIRED_PLUGINS.collect {
    Jenkins.instance.updateCenter.getPlugin(it).deploy()
  }.each {
    it.get()
  }
  Jenkins.instance.restart()
  println 'Run this script again after restarting to create the jobs!'
  throw new RestartRequiredException(null)
}

println "Plugins were installed successfully"
END5

sudo chown -R jenkins:jenkins ${var.JENKINS_HOME}/init.groovy.d

# restart Jenkins
sudo service jenkins restart

# Tools install
sudo apt-get install -y mariadb-client libmariadbclient18 awscli

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

# create iam user in target mysql
mysql -vvv -h ${aws_db_instance.dst_new.address} -P 3306 -u root -p${var.db_root_passwd} -e "CREATE DATABASE IF NOT EXISTS dms_sample"
mysql -vvv -h ${aws_db_instance.dst_new.address} -P 3306 -u root -p${var.db_root_passwd} -e "CREATE USER IF NOT EXISTS iam_admin IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS'"
mysql -vvv -h ${aws_db_instance.dst_new.address} -P 3306 -u root -p${var.db_root_passwd} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON dms_sample.* TO 'iam_admin'@'%' REQUIRE SSL"

# create iam user in source mysql
mysql -vvv -h ${aws_db_instance.src_old.address} -P 3306 -u root -p${var.db_root_passwd} -e "CREATE DATABASE IF NOT EXISTS dms_sample"
mysql -vvv -h ${aws_db_instance.src_old.address} -P 3306 -u root -p${var.db_root_passwd} -e "CREATE USER iam_admin IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS'" || true
mysql -vvv -h ${aws_db_instance.src_old.address} -P 3306 -u root -p${var.db_root_passwd} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON dms_sample.* TO 'iam_admin'@'%' REQUIRE SSL"

# restart Jenkins
sudo service jenkins restart

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
