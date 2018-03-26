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
end_day = Date.today.to_s # 実行日の前日までのコストは、AWSではDate.todayまででよい
# ∵ end_dayを本日としてdailyコストを取得した場合、
#   各daily costが「1~2日」=1日の間、「2~3日」=2日、……「前日〜本日」=前日の間 となる

ce = Aws::CostExplorer::Client.new

# services = ce.get_dimension_values({
#   # search_string: "",
#   time_period: { # required
#     start: start_day, # required
#   end: end_day, # required
#   },
#   dimension: "SERVICE", # required, accepts AZ, INSTANCE_TYPE, LINKED_ACCOUNT, OPERATION, PURCHASE_TYPE, REGION, SERVICE, USAGE_TYPE, USAGE_TYPE_GROUP, RECORD_TYPE, OPERATING_SYSTEM, TENANCY, SCOPE, PLATFORM, SUBSCRIPTION_ID, LEGAL_ENTITY_NAME, DEPLOYMENT_OPTION, DATABASE_ENGINE, CACHE_ENGINE, INSTANCE_TYPE_FAMILY
#   context: "COST_AND_USAGE", # accepts COST_AND_USAGE, RESERVATIONS
#   # next_page_token: "NextPageToken",
# })
#
# values = []
#
# for num in 0..30
#    values << resp[0][num].value
#    # puts resp[0][num].value
# end

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
      values: ["AWS CloudTrail", "AWS CodeCommit", "AWS Config", "AWS Data Pipeline", "AWS Database Migration Service", "AWS Key Management Service", "AWS Lambda", "AWS Support (Business)", "Amazon API Gateway", "Amazon CloudFront", "Amazon CloudSearch", "Amazon DynamoDB", "Amazon EC2 Container Registry (ECR)", "Amazon ElastiCache", "EC2 - Other", "Amazon Elastic Compute Cloud - Compute", "Amazon Elastic Load Balancing", "Amazon Elastic MapReduce", "Amazon Elasticsearch Service", "Amazon QuickSight", "Amazon Rekognition", "Amazon Relational Database Service", "Amazon Route 53", "Amazon Simple Email Service", "Amazon Simple Notification Service", "Amazon Simple Queue Service", "Amazon Simple Storage Service", "Amazon SimpleDB", "Amazon Virtual Private Cloud", "AmazonCloudWatch", "Tax"],
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

costs = []

for service in 0..29
  struct = resp.results_by_time[0]["groups"][service]
  cost = struct["metrics"]["BlendedCost"].amount.to_i
  puts struct.keys[0] + ": " + cost.to_s
  costs << cost
end
p costs.inject{ |sum, i| sum + i }
