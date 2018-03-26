require "aws-sdk"
require "aws-sdk-costexplorer"
require "json"
require "date"

creds = JSON.load(File.read("../Documents/credentials/aws_credentials.json")) # credentialsはファイル分ける
Aws.config.update({
  region: "us-east-1", # ap-northeast-1はinvalid region
  credentials: Aws::Credentials.new(creds["Access key ID"], creds["Secret access key"])
})

start_day = Date.today.to_s.slice(0,8) + "01" # 月初
end_day = (Date.today - 1).to_s # 実行日の前日

ce = Aws::CostExplorer::Client.new

resp = ce.get_cost_and_usage(params={
  time_period: {
    start: start_day, # required
    end: end_day, # required
  },
  granularity: "MONTHLY", # accepts DAILY, MONTHLY
  filter: {
    # or: [
    #   {
    #     # recursive Expression
    #   },
    # ],
    # and: [
    #   {
    #     # recursive Expression
    #   },
    # ],
    # not: {
    #   # recursive Expression
    # },
    dimensions: {
      key: "SERVICE", # accepts AZ, INSTANCE_TYPE, LINKED_ACCOUNT, OPERATION, PURCHASE_TYPE, REGION, SERVICE, USAGE_TYPE, USAGE_TYPE_GROUP, RECORD_TYPE, OPERATING_SYSTEM, TENANCY, SCOPE, PLATFORM, SUBSCRIPTION_ID, LEGAL_ENTITY_NAME, DEPLOYMENT_OPTION, DATABASE_ENGINE, CACHE_ENGINE, INSTANCE_TYPE_FAMILY
      values: ["EC2-Instances", "DynamoDB"],
    },
    # tags: {
    #   key: "TagKey",
    #   values: ["Value"],
    # },
  },
  metrics: ["BlendedCost"],
  group_by: [
    {
      type: "DIMENSION", # accepts DIMENSION, TAG
      key: "SERVICE",
    },
  ],
  # next_page_token: "NextPageToken",
})

puts resp.results_by_time#[0].total["BlendedCost"].amount
