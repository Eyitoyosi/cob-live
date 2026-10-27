# cob-live

Live infrastructure configuration for Beejan Technologies, built on the
[COB platform](https://github.com/Eyitoyosi/cob). This repository **consumes**
COB; it does not contain platform code. Every module call pins a released
COB version.

## Structure

```
cob-live/
├── bootstrap/        # One-time: creates the Terraform state bucket and lock table
│                      # (local state, run once by an admin)
└── environments/
    ├── dev/
    │   ├── foundation/   # Shared VPC + ECS cluster, owned by Platform Engineering
    │   └── teams/
    │       ├── app-engineering/
    │       ├── data-engineering/
    │       └── analytics-engineering/
    └── prod/
        └── (same shape as dev)
```

Why state is split this way: see `0001` and `0005` in
[`cob/docs/decisions/`](https://github.com/<org>/cob/tree/main/docs/decisions).

## Quick start

Prerequisites: Terraform >= 1.5.0, AWS CLI configured
(`aws sts get-caller-identity` succeeds), and Git access to the `cob`
repository (`ssh -T git@github.com` if it is private).

1. Bootstrap the state backend (once, ever):
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```
2. Provision the shared foundation for an environment:
   ```bash
   cd environments/dev/foundation
   terraform init
   terraform apply -var-file=dev.tfvars
   ```
3. Provision a team's workload (after foundation exists):
   ```bash
   cd environments/dev/teams/app-engineering
   terraform init
   terraform apply
   ```

Always pass the same `-var-file` to `destroy` that you passed to `apply`.

## Upgrading to a new COB release

1. Read the release notes for the new tag in the `cob` repository.
2. Find every pinned reference:
   ```bash
   grep -rn "ref=" environments/
   ```
3. Change `ref=vX.Y.Z` to the new version in **dev** first.
4. `terraform init` then `terraform plan -var-file=dev.tfvars`. Read the plan.
5. Apply in dev. Once it looks healthy, repeat for prod.

To roll back, set the `ref` back to the previous tag and plan again.

## Conventions

- `*.tfvars` files are committed. They hold only environment settings such as
  CIDR ranges, never secrets. Credentials are generated and stored in Secrets
  Manager by the modules.
- `.terraform.lock.hcl` is committed in every root module so everyone and
  every pipeline uses the same provider versions.
- State files and `.terraform/` are never committed.
