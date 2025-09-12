# Day 10 – Networking with Terraform (VPC, Public & Private Subnets, NAT Gateway) 🌐

**Date:** 2025-09-02
**Day Branch:** `day-10-vpc-subnets`
**Topic:** Provisioning AWS networking with Terraform: VPC, subnets, Internet Gateway, route tables, and NAT gateway.

---

## 🎯 Goals

* [x] Expand the Terraform `networking` module to include **private subnets**.
* [x] Implement a **single cost-effective NAT gateway** for private subnet internet access.
* [x] Reuse existing **public subnets** from Day 9.
* [x] Configure route tables to link public → IGW and private → NAT.
* [x] Tag resources consistently for **FinOps** and easy identification.
* [x] Update CI workflow to validate the extended configuration.

---

## ✅ What I Did

1. **Updated Networking Module (`modules/networking/`)**

   * Added Terraform resources for two **private subnets** (`10.0.11.0/24` and `10.0.12.0/24`).
   * Created one **NAT Gateway** inside the first public subnet.
   * Defined a private route table pointing traffic (`0.0.0.0/0`) to the NAT.
   * Associated private subnets with the new private route table.
   * Reused public subnets + IGW setup from Day 9.

2. **Environment Code (`envs/dev/`)**

   * Called the updated networking module with variables for CIDRs, subnets, and tags.
   * Verified remote state backend still worked (S3 + DynamoDB lock).

3. **CI Workflow (`.github/workflows/terraform-ci.yml`)**

   * Extended the Terraform CI pipeline to validate the new networking resources.
   * Ran `terraform fmt`, `terraform validate`, and `tflint` to enforce standards.
   * Ensured PR checks catch misconfigurations before applying.

---

## 📚 Key Concepts I Learned

* **NAT Gateway vs. Internet Gateway**:

  * IGW is for public subnets (resources directly reachable from internet).
  * NAT lets private subnets initiate outbound traffic (like downloading updates) but blocks inbound.

* **Subnet Types**:

  * Public = `map_public_ip_on_launch = true` + route to IGW.
  * Private = no public IPs, route via NAT gateway.

* **Single NAT Tradeoff**:

  * Cheaper than HA NATs, but if the AZ with NAT fails, private subnet traffic fails too.
  * Acceptable for dev environments; prod usually uses 2+ NATs.

* **Terraform Design**:

  * Modules = reusable blocks for networking, compute, etc.
  * Envs (`dev`, `prod`) call modules with different vars.

---

## 🛠 Commands I Ran

```bash
# Format and validate Terraform code
terraform fmt -recursive
terraform validate

# Initialize and pull backend state (S3 + DynamoDB lock)
terraform init

# Preview changes
terraform plan -var-file=envs/dev/terraform.tfvars

# Apply changes to AWS
terraform apply -var-file=envs/dev/terraform.tfvars

# CI runs automatically on push
gh pr create --title "Day 10 – VPC with Public & Private Subnets, NAT" --body "Networking expansion with NAT support"
```

---

## ✅ Achievements

* Working **VPC with public and private subnets**.
* **Internet access enabled** in private subnets via NAT gateway.
* Extended CI workflow to cover networking.
* All resources tagged consistently for cost tracking.

---

## 🤔 Reflections

* Networking feels like “plumbing” for AWS — it’s invisible but critical.
* NAT gateways can get expensive if you add one per AZ, so designing wisely is part of DevOps maturity.
* With Day 10 done, my infra is now **production-like** (split public/private).

---

## 🔮 Next Steps (Day 11 Preview)

* Provision a **PostgreSQL RDS instance** inside the private subnets.
* Add **security groups** to restrict DB access.
* Explore **Secrets Manager** for credential handling.

---

⚡ *By Day 10, I’ve built a secure network foundation in AWS with Terraform — a big step toward real-world infra readiness.*
