### Install terraform

### Create file ./terraform.tfvars.json

Add the following content:
```
{
  "db_root_passwd": "foobarbaz"
}
```

```bash
terraform init
terraform validate
AWS_PROFILE=dev terraform plan
AWS_PROFILE=dev terraform apply --auto-approve
```