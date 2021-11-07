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

# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

/*
resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}
*/

resource "aws_dms_replication_subnet_group" "test" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"

/*
  subnet_ids = [
    "subnet-12345678",
  ]
*/

  subnet_ids = [
    module.vpc.subnet_private1_id, module.vpc.subnet_private2_id
  ]

}

# Create a replication instance
resource "aws_dms_replication_instance" "src-to-dest" {
  replication_instance_id      = "src-to-dest-replication-instance"
  replication_instance_class   = "dms.t3.micro"
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  availability_zone            = "us-west-2b"
  engine_version               = "3.4.5"
  /* kms_key_arn                  = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012" */
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = false

  replication_subnet_group_id  = aws_dms_replication_subnet_group.test.id
  /* replication_subnet_group_id  = aws_db_subnet_group.default.id */

  vpc_security_group_ids = [ aws_security_group.ec2-sg.id ]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    /* aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole */
  ]
}


/*
{
    "ReplicationInstances": [
        {
            "ReplicationInstanceIdentifier": "src-to-dst", +
            "ReplicationInstanceClass": "dms.t3.micro", + 
            "ReplicationInstanceStatus": "available", - 
            "AllocatedStorage": 50, +
            "InstanceCreateTime": "2021-11-05T15:04:58.862000+00:00", - 
            "VpcSecurityGroups": [ ???
                {
                    "VpcSecurityGroupId": "sg-05ab94a42dfb14345",
                    "Status": "active"
                }
            ],
            "AvailabilityZone": "us-west-2b", +
            "ReplicationSubnetGroup": {
                "ReplicationSubnetGroupIdentifier": "default-vpc-0106c25dcb42e27dd",
                "ReplicationSubnetGroupDescription": "default group created by console for vpc id vpc-0106c25dcb42e27dd",
                "VpcId": "vpc-0106c25dcb42e27dd",
                "SubnetGroupStatus": "Complete",
                "Subnets": [
                    {
                        "SubnetIdentifier": "subnet-0ec34227274170612",
                        "SubnetAvailabilityZone": {
                            "Name": "us-west-2a"
                        },
                        "SubnetStatus": "Active"
                    },
                    {
                        "SubnetIdentifier": "subnet-052de586e91b3f428",
                        "SubnetAvailabilityZone": {
                            "Name": "us-west-2b"
                        },
                        "SubnetStatus": "Active"
                    },
                    {
                        "SubnetIdentifier": "subnet-078d2b23a1a14df15",
                        "SubnetAvailabilityZone": {
                            "Name": "us-west-2a"
                        },
                        "SubnetStatus": "Active"
                    }
                ]
            },
            "PreferredMaintenanceWindow": "mon:05:19-mon:05:49", +
            "PendingModifiedValues": {},
            "MultiAZ": false, +
            "EngineVersion": "3.4.5", +
            "AutoMinorVersionUpgrade": true, +
            "KmsKeyId": "arn:aws:kms:us-west-2:627223132631:key/cca0c843-5b62-421b-ba66-afbe6f48cac5",
            "ReplicationInstanceArn": "arn:aws:dms:us-west-2:627223132631:rep:CHA34TO2X6DMR7BFJB3QMLTLCDMP4TMFVVERANI",
            "ReplicationInstancePrivateIpAddress": "192.168.3.206",
            "ReplicationInstancePublicIpAddresses": [
                null
            ],
            "ReplicationInstancePrivateIpAddresses": [
                "192.168.3.206"
            ],
            "PubliclyAccessible": false +
        }
    ]
}
*/