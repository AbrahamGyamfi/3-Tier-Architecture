# 3-Tier AWS Architecture with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

Enterprise-grade, highly available 3-tier web application infrastructure with comprehensive security controls.

## Architecture Overview

```
Internet → IGW → ALB (Public) → EC2 ASG (Private) → RDS MySQL Multi-AZ (Private)
                                      ↓
                              Secrets Manager + KMS
```

**Components:**
- **Presentation Layer**: Application Load Balancer in public subnets
- **Application Layer**: Auto Scaling Group (2-4 EC2 t3.micro instances) in private subnets
- **Data Layer**: RDS MySQL Multi-AZ + Read Replica in private DB subnets
- **High Availability**: Multi-AZ deployment across 2 availability zones

![Architecture Diagram](3-TierDiagram.jpg)

## Security Features

### 🔐 Encryption & Key Management
- **Customer-Managed KMS Keys**: Separate keys for RDS, Secrets Manager, and EBS
- **Automatic Key Rotation**: Enabled on all KMS keys
- **Encryption at Rest**: RDS, EBS volumes, Secrets Manager, and Terraform state
- **Audit Trail**: All key usage logged via CloudTrail

### 🔒 Secrets Management
- **AWS Secrets Manager**: Auto-generated 24-character passwords
- **Zero Hardcoded Credentials**: No passwords in code or Git
- **Least Privilege Access**: EC2 instances can only read specific secrets
- **7-Day Recovery Window**: Protection against accidental deletion

### 👤 Identity & Access Management
- **IAM Roles**: EC2 instances use roles (no access keys)
- **SSM Session Manager**: Secure shell access without SSH keys or bastion hosts
- **Least Privilege Policies**: Minimal permissions for Secrets Manager and KMS

### 🛡️ Network Security
- **Security Groups**: Layered firewall (ALB → App → DB)
- **Private Subnets**: App and DB tiers isolated from internet
- **No Public IPs**: EC2 and RDS use private IPs only
- **NAT Gateway**: Controlled outbound access for updates

### ✅ Security Controls
- No credentials in code or version control
- No SSH keys or bastion hosts required
- No public database endpoints
- No unencrypted data at rest
- No single points of failure

## Infrastructure Components

```
IaC/
├── modules/
│   ├── kms/              # Customer-managed encryption keys
│   ├── secrets/          # Secrets Manager with auto-generated passwords
│   ├── iam/              # IAM roles and least-privilege policies
│   ├── networking/       # VPC, subnets, NAT, IGW
│   ├── security/         # Security groups
│   ├── alb/              # Application Load Balancer
│   ├── compute/          # Auto Scaling Group + Launch Template
│   └── database/         # RDS MySQL Multi-AZ + Read Replica
├── main.tf
├── provider.tf           # S3 backend with encryption
├── variables.tf
└── terraform.tfvars      # Gitignored
```

**Resources**: ~55 (VPC, 6 subnets, 3 KMS keys, 3 security groups, ALB, ASG, RDS Multi-AZ + replica)

## Prerequisites

- Terraform v1.0+
- AWS CLI v2.x configured
- AWS account with appropriate permissions
- (Optional) ACM certificate for HTTPS

## Quick Start

### 1. Setup Backend (First Time)

```bash
# Create S3 bucket for state
BUCKET_NAME="3tier-terraform-state-$(date +%s)"
aws s3api create-bucket --bucket $BUCKET_NAME --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1
aws s3api put-bucket-versioning --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $BUCKET_NAME \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Create DynamoDB table for state locking
aws dynamodb create-table --table-name 3tier-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region eu-west-1
```

Update `provider.tf` with your bucket name.

### 2. Deploy Infrastructure

```bash
cd IaC
terraform init
terraform plan    # Review ~55 resources
terraform apply   # Takes 10-15 minutes
```

### 3. Get Outputs

```bash
terraform output
# alb_dns - Application URL
# rds_endpoint - Database endpoint
# secret_name - Secrets Manager secret name
```

## Configuration

Key variables in `terraform.tfvars`:

```hcl
aws_region  = "eu-west-1"
environment = "production"
project     = "3tier-iac"
db_username = "admin"
# certificate_arn = "arn:aws:acm:..." # Optional for HTTPS
```

## Security Operations

### Retrieve Database Password

```bash
aws secretsmanager get-secret-value \
  --secret-id 3tier-iac-db-credentials \
  --query SecretString --output text | jq -r '.password'
```

### Access EC2 Instances (No SSH Keys)

```bash
# List instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=3tier-app-instance" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress]' \
  --output table

# Connect via SSM Session Manager
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=3tier-app-instance" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws ssm start-session --target $INSTANCE_ID
```

### Verify Security

```bash
# Verify RDS encryption
aws rds describe-db-instances --db-instance-identifier 3tier-iac-db \
  --query 'DBInstances[0].[StorageEncrypted,PubliclyAccessible]'
# Expected: [true, false]

# List KMS keys
aws kms list-aliases | grep 3tier-iac
```

## Testing

```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns)

# Test application
curl http://$ALB_DNS

# Check health
curl -I http://$ALB_DNS/health
```

## Troubleshooting

**EC2 Instances Unhealthy:**
```bash
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)
aws ssm start-session --target $INSTANCE_ID
sudo journalctl -u todo-app -f
```

**Cannot Connect to RDS:**
```bash
# Verify security group allows traffic from app tier
terraform output rds_endpoint
# Test from EC2: telnet <rds-endpoint> 3306
```

## Cleanup

```bash
terraform destroy
```

Force delete secrets (skip 7-day recovery):
```bash
aws secretsmanager delete-secret --secret-id 3tier-iac-db-credentials \
  --force-delete-without-recovery
```

## Screenshots

| Component | Screenshot |
|-----------|------------|
| ALB | ![ALB](Screenshot/ALB_shot.png) |
| Auto Scaling | ![ASG](Screenshot/AutoScaling.png) |
| RDS | ![RDS](Screenshot/RDS_Shot.png) |
| VPC | ![VPC](Screenshot/VPC_shot.png) |
| App Connected | ![App](Screenshot/APP_Connected_To%20_DB.png) |


**Built with Terraform following AWS Well-Architected Framework security best practices**
