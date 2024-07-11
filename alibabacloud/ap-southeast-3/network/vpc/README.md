terraform init
terraform workspace select management
terraform apply -var-file management.tfvars

====
terraform init
terraform workspace select staging
terraform apply -var-file staging.tfvars

====
terraform init
terraform workspace select production
terraform apply -var-file production.tfvars