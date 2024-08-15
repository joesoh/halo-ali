# Staging Command

export AWS_PROFILE=staging
terraform workspace select staging
tfenv install min-required && terraform init && terraform apply

# Production Command

export AWS_PROFILE=production
terraform workspace select production
tfenv install min-required && terraform init && terraform apply