require "aws-sdk"
require "aws-sdk-costexplorer"
require "json"

creds = JSON.load(File.read("../Documents/credentials/aws_credentials.json")) # credentialsはファイル分ける
Aws.config.update({
  region: "us-east-1", # ap-northeast-1はinvalid region
  credentials: Aws::Credentials.new(creds["Access key ID"], creds["Secret access key"])
})
ce = Aws::CostExplorer::Client.new
ce.get_cost_and_usage({
  time_period: {
    start: "YearMonthDay", # required
    end: "YearMonthDay", # required
  },
  granularity: "DAILY", # accepts DAILY, MONTHLY
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
      values: ["CrowdTrail"],
    },
    # tags: {
    #   key: "TagKey",
    #   values: ["Value"],
    # },
  },
  # metrics: ["MetricName"],
  # group_by: [
  #   {
  #     type: "DIMENSION", # accepts DIMENSION, TAG
  #     key: "GroupDefinitionKey",
  #   },
  # ],
  # next_page_token: "NextPageToken",
})
