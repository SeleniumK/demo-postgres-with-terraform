# demo-postgres-with-terraform
A simple demo of the ways you can manage databases, users, and permissions with terraform.

Demoed at PGCon NYC 2024 (slides to be linked at a later point)

Installing Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

To get started, make sure you have postgres running locally (or adjust the provider details in main.tf)

This demo relies on a few env variables (or passing the variables into your terraform commands -- See https://developer.hashicorp.com/terraform/language/values/variables)

The tf variables are defined in _variables.tf, you can set these in your environment with the prefix TF_VAR_ like so:
```
export TF_VAR_pgcon_superuser_password="foo"
export TF_VAR_pgcon_application_password="bar"
export TF_VAR_pgcon_readonly_password="baz"
export TF_VAR_pgcon_limited_password="bazooka"
```

To provision these database resources, use the terraform standard commands in this directory
```
terraform init
terraform plan
terraform apply
```

For easy removal of the resources, run the following in this directory
```
terraform destroy
```

Have fun! And a special thanks to cyrilgdn for maintaining this provider!

Check it out @ https://github.com/cyrilgdn/terraform-provider-postgresql