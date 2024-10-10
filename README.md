# Terraform AWS Infrastructure

This repository contains Terraform configuration files to set up and manage AWS infrastructure.

## Project Structure

- **.github/**: Contains GitHub workflows and actions.
- **.terraform/**: Directory for Terraform plugins and modules.
- **modules/**: Custom Terraform modules used in the configuration.
- **.gitignore**: Specifies files and directories to be ignored by Git.
- **.terraform.lock.hcl**: Lock file to ensure consistent Terraform runs.
- **main.tf**: Main configuration file defining the infrastructure.
- **outputs.tf**: Specifies the outputs of the Terraform configuration.
- **README.md**: Documentation for setting up and using the infrastructure.
- **terraform.tfstate**: State file tracking the current state of the infrastructure.
- **terraform.tfstate.backup**: Backup of the state file.
- **terraform.tfvars**: Variables file for configuring the infrastructure.
- **variables.tf**: Defines input variables for the configuration.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed on your machine.
- AWS account with appropriate permissions.

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone {tf-aws-infra repo}
   cd tf-aws-infra
   ```

2. **Configure AWS Credentials**

   Ensure your AWS credentials are set up, either through environment variables or an AWS credentials file.

3. **Initialize Terraform**

   Initialize the Terraform working directory, which will download necessary plugins:
   ```bash
   terraform init
   ```

4. **Review and Edit Variables**

   Edit `terraform.tfvars` to customize variables such as region, instance types, etc.

5. **Plan the Changes**

   Generate an execution plan to preview changes:
   ```bash
   terraform plan
   ```

6. **Apply the Configuration**

   Apply the changes required to reach the desired state of the configuration:
   ```bash
   terraform apply
   ```

7. **Verify Outputs**

   After applying, check `outputs.tf` for information on accessing your resources.

8. **Destroy the Infrastructure (if needed)**

   To remove all resources managed by Terraform:
   ```bash
   terraform destroy
   ```

