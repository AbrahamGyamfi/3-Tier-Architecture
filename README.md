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

![3-Tier Architecture Diagram](Screenshot/Architecture_Diagram.drawio.png)

---

## Screenshots

### ALB in AWS Console
![ALB Screenshot](Screenshot/ALB_shot.png)

### Successful ICMP (ping) Response
![ICMP Test](Screenshot/ICMP_Test.png)

### EC2 Auto Scaling Group
![Auto Scaling Group](Screenshot/AutoScaling.png)

### RDS Database Instance
![RDS Screenshot](Screenshot/RDS_Shot.png)

### VPC and Subnets
![VPC Screenshot](Screenshot/VPC_shot.png)

### Application Connected to Database
![App Connected to DB](Screenshot/APP_Connected_To%20_DB.png)

### Terraform Apply Output
![Terraform Output](Screenshot/Terraform_output.png)

---

## Notes
- All modules are reusable and parameterized
- Only allowed regions and t3.micro instance types are used
- Tagging follows: `Environment`, `Project`, `Owner`
