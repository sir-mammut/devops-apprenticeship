# Day 09 – Terraform Modules, Envs & CI Matrix 🚦

**Date:** 2025-09-01
**Day Branch:** `day-09-modular-terraform`
**Topic:** Extract networking into a reusable **module**, create a dedicated **dev environment**, and upgrade CI to a **matrix** that runs fmt/validate/tflint across modules and envs.

---

## 🎯 Goals

* [x] Turn Day 8 networking into a **reusable Terraform module**.
* [x] Create **`envs/dev`** that consumes the module (region: `eu-north-1`).
* [x] Keep remote state on S3 with DynamoDB **locking**.
* [x] Upgrade CI to **matrix** over module/env directories (fmt, validate, tflint).
* [x] Document a clean, reproducible workflow.

---

## 🧱 What I Built

### 1) Reusable networking module

* **VPC** (`10.0.0.0/16`) with **2 public subnets** in distinct AZs
* **Internet Gateway**, **public route table**, **default route** to IGW
* **Associations** for public subnets → public RT
* Tagged with `Project`, `Environment`, `ManagedBy` where relevant

**Key outputs:** `vpc_id`, `public_subnet_ids`, `public_route_table_id`, `igw_id`.

### 2) `envs/dev` environment

* Provider pinned to `eu-north-1`, profile `devops-tf`
* Remote backend:

  * **bucket:** `devops-apprenticeship-terraform-state`
  * **key:** `envs/dev/terraform.tfstate`
  * **region:** `eu-north-1`
  * **dynamodb\_table:** `terraform-state-lock`
* Calls the module with explicit inputs (CIDRs, env tag)

### 3) CI upgrade (GitHub Actions)

* Matrix over:

  * `infra/terraform/modules/networking`
  * `infra/terraform/envs/dev`
* Steps per directory: `terraform fmt -check`, `init -backend=false`, `validate`, `tflint`

---

## 📁 Repo Layout (new/updated)

```text
infra/terraform/
├─ modules/
│  └─ networking/
│     ├─ main.tf
│     ├─ variables.tf
│     └─ outputs.tf
└─ envs/
   └─ dev/
      ├─ backend.tf
      ├─ main.tf
      ├─ variables.tf
      └─ outputs.tf

.github/workflows/terraform-ci.yml
journal/day09.md
```

---

## 🛠 Code I Wrote (highlights)

### Module invocation (envs/dev/main.tf)

```hcl
provider "aws" {
  region  = var.aws_region         # eu-north-1
  profile = var.aws_profile        # devops-tf
  default_tags { tags = { Project = "devops-apprenticeship", Environment = var.environment, ManagedBy = "Terraform" } }
}

module "networking" {
  source              = "../../modules/networking"
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}
```

### Backend (envs/dev/backend.tf)

```hcl
terraform {
  backend "s3" {
    bucket         = "devops-apprenticeship-terraform-state"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "devops-tf"
  }
}
```

---

## 🧪 Commands I Ran

```bash
# Branch
git checkout -b day-09-modular-terraform

# Local checks before any apply
cd infra/terraform/envs/dev
terraform init                      # uses remote backend
terraform fmt -recursive
terraform validate
tflint --init && tflint

# Plan & apply dev env
terraform plan -out plan.bin
terraform apply plan.bin

# Outputs (for clipboard/testing)
terraform output -json | jq
```

---

## 🧭 CI Pipeline (what it does)

* **Matrix** over module + env directories.
* `terraform fmt -check -recursive` enforces style.
* `terraform init -backend=false` avoids backend access in PR validation.
* `terraform validate` + `tflint` catch mistakes early.
* Easy to add more dirs (e.g., `envs/prod`) to the matrix.

---

## 🧯 Issues I Anticipated / Avoided

* **Region mismatch** (S3 in `eu-north-1`): Backend block set explicitly to the bucket’s region.
* **Permissions boundary** on IAM user: Requires S3 **List/Get/Put** and DynamoDB **Get/Put/DeleteItem** for locking.
* **Accidental state commits**: `terraform.tfstate` and `.terraform/` are ignored by `.gitignore`.
* **Wrong backend `key`**: Remember it’s a **path**, not an ARN.

---

## 📤 Outputs to Save

* `vpc_id`, `public_subnet_ids[]`, `public_route_table_id`, `igw_id`
* Useful for wiring compute later (EC2/ECS/EKS).

---

## ✅ Acceptance Criteria

* `terraform plan` & `apply` **succeed** from `envs/dev`.
* AWS console (eu-north-1) shows VPC, 2 public subnets (2 AZs), IGW, public route, associations.
* CI **green** on PR: fmt/validate/tflint pass for module and env.

---

## 🤔 Reflection

Module-izing wasn’t about “moving files”; it’s about **creating a contract**: inputs, outputs, and guarantees. The CI matrix enforces that contract across directories—no more “it works locally but not in PR.” This is the difference between scripts and real infrastructure engineering.

---

## 🔮 Next Steps (Day 10 preview)

* Add **`tfsec`** (security scan) locally + CI with SARIF upload.
* Introduce **`envs/prod`** (plan-only in CI, manual apply).
* Consider `pre-commit` hooks (`fmt`, `validate`, `tflint`, `tfsec`) for local guardrails.

---
