# Day 08 – Terraform Foundations: Remote State, VPC, CI 🚀

**Date:** 2025-08-31
**Day Branch:** `day-08-terraform-bootstrap`
**Topic:** Install & pin Terraform, bootstrap remote state (S3 + DynamoDB), build a minimal VPC, wire up fmt/validate/TFLint in CI.

---

## 🎯 Goals

* [x] Install & pin Terraform; scaffold a clean `infra/terraform` layout.
* [x] Create **S3 (versioned, encrypted)** + **DynamoDB** for remote state & locking.
* [x] Migrate state to S3 and verify locking.
* [x] Provision a **VPC**: `/16` CIDR, **2 public subnets** across AZs, **IGW**, routes, and an app SG (3000/tcp).
* [x] Add **TFLint**, `terraform fmt`, `terraform validate` locally & in **GitHub Actions**.

---

## 🧱 What I built

**Infrastructure**

* **S3 bucket** for Terraform state (private, versioned, AES256 SSE).
* **DynamoDB table** (`terraform-state-lock`) for state locking.
* **VPC** `10.0.0.0/16`, **public subnets** in 2 AZs, **IGW**, public route table (`0.0.0.0/0 → IGW`).
* **Security Group** `app-sg-3000` (ingress 3000/tcp from 0.0.0.0/0, egress all).

**Tooling**

* `infra/terraform` scaffold (`versions.tf`, `providers.tf`, `variables.tf`, `backend.tf`, `backend.hcl`, `state_bootstrap.tf`, `network.tf`, `.tflint.hcl`, `.gitignore`).
* CI workflow `.github/workflows/terraform-ci.yml`:

  * `terraform fmt -check -recursive`
  * `terraform validate`
  * `tflint` (+ ruleset init)

---

## 🗂 Repo Layout

```
infra/
  terraform/
    .gitignore
    versions.tf
    variables.tf
    providers.tf
    backend.tf
    backend.hcl
    state_bootstrap.tf   # creates S3 & DynamoDB (first apply w/ local state)
    network.tf           # VPC + subnets + IGW + routes + SG
    .tflint.hcl
.github/
  workflows/
    terraform-ci.yml
journal/
  day08.md   # this file
```

---

## 🧪 Commands I ran (happy path)

```bash
# From repo root
direnv allow   # loads AWS_PROFILE/REGION if you put them in .envrc

cd infra/terraform

# First pass: create remote state infra (LOCAL state)
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out plan-bootstrap.bin
terraform apply plan-bootstrap.bin

# Migrate to remote S3 backend (edit backend.hcl with your bucket/region/table)
terraform init -backend-config=backend.hcl -reconfigure -migrate-state

# Provision VPC
terraform fmt -recursive
terraform validate
tflint --init && tflint
terraform plan -out plan-vpc.bin
terraform apply plan-vpc.bin
```

---

## 🛡️ Gotchas I hit (and fixed)

* **Typed an ARN into backend `key`** → `key` must be a *path* inside S3, e.g. `env/dev/terraform.tfstate`.
* **S3 301 redirect on init** → bucket was in **eu-north-1** while backend said **us-east-1**. Fixed `region` in `backend.hcl` to match bucket region.
* **AccessDenied on S3 (`ListBucket`, `GetBucketLocation`)** → an **IAM permissions boundary** blocked actions.

  * **Debug loop:** `get-user` → dump boundary policy → `simulate-principal-policy` → update boundary to allow `s3:ListBucket`, `Get/PutObject`, and DynamoDB `Get/Put/DeleteItem`.
  * Temporary workaround: run locally with the **local backend**, then migrate once boundary is fixed.

---

## 📤 Outputs to keep

* **S3 bucket name** (state)
* **DynamoDB table name** (lock)
* **VPC ID**, **Subnet IDs**, **Route table ID**, **Security Group ID**

These appear in `terraform apply` outputs and in AWS Console (VPC/S3/DynamoDB).

---

## ✅ Acceptance Criteria

* State stored in S3; `terraform plan` shows **“Acquiring state lock”** (DynamoDB).
* `terraform fmt -check`, `terraform validate`, and `tflint` all pass locally.
* GitHub Actions **Terraform CI** job is green.
* VPC/subnets/IGW/route/SG visible in AWS Console.

---

## 🔭 Next

* Day 9: **Terraform modules**, `tfsec` (security scanning), and environment separation.
* Day 10: **Terragrunt** intro + remote state per env.

---

## 🧠 Reflection

IaC isn’t “just write resources”; it’s **state hygiene + guardrails**. Remote state + locking *prevents drama*. Lint/format/validate in CI *prevents regressions*. This is how teams move fast **without** breaking prod.

---
