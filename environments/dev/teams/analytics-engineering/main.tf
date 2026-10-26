data "terraform_remote_state" "data_engineering" {
  backend = "s3"
  config = {
    bucket = "beejan-cob-terraform-main-state"
    key    = "dev/teams/data-engineering/terraform.tfstate"
    region = "us-east-1"
  }
}

module "orders_catalog" {
  source          = "git::https://github.com/Eyitoyosi/cob.git//modules/data-platform?ref=v0.1.0"
  name            = "orders"
  environment     = "dev"
  data_bucket_id  = data.terraform_remote_state.data_engineering.outputs.orders_bucket_id
  data_bucket_arn = data.terraform_remote_state.data_engineering.outputs.orders_bucket_arn
}

module "team_access" {
  source      = "git::https://github.com/Eyitoyosi/cob.git//modules/iam-team-access?ref=v0.1.0"
  team_name   = "analytics-engineering"
  environment = "dev"
  usernames   = ["kate.doe"]

  policy_statements = [
    {
      sid       = "QueryOrdersData"
      effect    = "Allow"
      actions   = ["athena:StartQueryExecution", "athena:GetQueryResults", "glue:GetTable", "glue:GetDatabase"]
      resources = ["*"]
    }
  ]
}