# 3-Tier AWS Architecture with Terraform Modules

## Architecture Overview

This project provisions a 3-tier AWS architecture using only Terraform native modules (no registry modules):

- **Presentation Layer:**
  - Application Load Balancer (ALB) in public subnets
- **Application Layer:**
  - EC2 instance (t3.micro) in private app subnets
- **Data Layer:**
  - RDS MySQL (t3.micro) in private DB subnets

All resources are parameterized, tagged, and region-restricted (eu-west-1, eu-central-1, us-east-1).

---

## Folder Structure

```
IaC/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── networking/
│   ├── security/
│   ├── alb/
│   ├── compute/
│   └── database/
```

---

## Deployment Instructions

1. **Clone the repository**
2. **Configure AWS credentials** (export AWS_PROFILE or set up credentials file)
3. **Edit `variables.tf`** to set your preferred region, owner, and DB password
4. **Run Terraform**:
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

---

## Module Descriptions

- **networking:** VPC, 2 public subnets, 2 private app subnets, 2 private DB subnets, IGW, NAT, route tables
- **security:** 3 security groups (web, app, db) with correct rules
- **alb:** Application Load Balancer, listener, target group
- **compute:** EC2 instance (t3.micro, Amazon Linux 2)
- **database:** RDS MySQL (t3.micro), DB subnet group

---

## Variables

See each module's `variables.tf` for all options. Key root variables:
- `aws_region` (must be eu-west-1, eu-central-1, or us-east-1)
- `owner` (for tagging)
- `db_password` (set a secure password)

---

## Outputs

- `alb_dns`: ALB DNS name
- `rds_endpoint`: RDS endpoint
- `instance_id`: EC2 instance ID

---

## Architecture Diagram

> _Insert your diagram here (draw.io, Lucidchart, etc.)_

---

## Screenshots

- ALB in AWS Console
- Successful ICMP (ping) from ALB target or bastion
- EC2/ASG in AWS Console
- RDS in AWS Console
- VPC/Subnets in AWS Console
- Output from `terraform apply`

---

## Notes
- All modules are reusable and parameterized
- Only allowed regions and t3.micro instance types are used
- Tagging follows: `Environment`, `Project`, `Owner`
