require "aws-sdk"
require "aws-sdk-costexplorer"
require "json"
require "date"
require "pry"
require "expanded_date"
require_relative "aws_config"
require_relative "spreadsheet"

include AwsConfig
include SpreadSheet
include Authorize

Authorize.authorize

AwsConfig.ce_client
ce = Aws::CostExplorer::Client.new

start_day = Date.today.to_s.slice(0,8) + "01" # 月初
end_day = Date.today.to_s # 実行日の前日までのコストは、AWSではDate.todayまででよい
# ∵ end_dayを本日としてdailyコストを取得した場合、
#   各daily costが「1~2日」=1日の間、「2~3日」=2日、……「前日〜本日」=前日の間 となる
past_days = end_day.slice(8,9).to_i - start_day.slice(8,9).to_i # 月初から前日までの日数
last_day = Date.today.end_of_month.mday # 今月末の日付 (integerなので注意)

keys = ["Amazon Simple Storage Service", "Amazon EC2 Container Registry (ECR)", "Amazon CloudSearch", "Amazon Relational Database Service", "Amazon DynamoDB", "Amazon CloudFront", "Amazon ElastiCache"]

responses = ce.get_cost_and_usage(
  params={
    time_period: {
      start: start_day, # required
    end: end_day # required
    },
    granularity: "MONTHLY", # accepts DAILY, MONTHLY
    filter: {
      dimensions: {
        key: "SERVICE", # accepts AZ, INSTANCE_TYPE, LINKED_ACCOUNT, OPERATION, PURCHASE_TYPE, REGION, SERVICE, USAGE_TYPE, USAGE_TYPE_GROUP, RECORD_TYPE, OPERATING_SYSTEM, TENANCY, SCOPE, PLATFORM, SUBSCRIPTION_ID, LEGAL_ENTITY_NAME, DEPLOYMENT_OPTION, DATABASE_ENGINE, CACHE_ENGINE, INSTANCE_TYPE_FAMILY
        values: ["Amazon Simple Storage Service", "Amazon EC2 Container Registry (ECR)", "Amazon CloudSearch", "Amazon Relational Database Service", "Amazon DynamoDB", "Amazon CloudFront", "Amazon ElastiCache", "AWS CloudTrail", "AWS CodeCommit", "AWS Config", "AWS Data Pipeline", "AWS Database Migration Service", "AWS Key Management Service", "AWS Lambda", "AWS Support (Business)", "Amazon API Gateway", "EC2 - Other", "Amazon Elastic Compute Cloud - Compute", "Amazon Elastic Load Balancing", "Amazon Elastic MapReduce", "Amazon Elasticsearch Service", "Amazon QuickSight", "Amazon Rekognition", "Amazon Route 53", "Amazon Simple Email Service", "Amazon Simple Notification Service", "Amazon Simple Queue Service",  "Amazon SimpleDB", "Amazon Virtual Private Cloud", "AmazonCloudWatch", "Tax"] # all services
      },
    },
    metrics: ["BlendedCost"],
    group_by: [
      {
        type: "DIMENSION", # accepts DIMENSION, TAG
        key: "SERVICE"
      },
    ],
  }
)

historical_all = [] # 全サービスのHistorical Total
forecast_all = [] # 全サービスのForecast

responses.results_by_time[0]["groups"].each do |struct| # struct は object "Aws::CostExplorer::Types::GetDimensionValuesResponse"

  historical = struct["metrics"]["BlendedCost"].amount.to_f # 各サービスのHistorical Total
  puts trial.to_s + "Historical Total: " + struct.keys[0] + ": " + historical.to_s

  forecast = historical * (last_day - past_days) / past_days

  keys.each do |key|
    if struct.keys[0] == key
      puts "Forecast Total: " + struct.keys[0] + ": " + forecast.to_s # 確認用
    end
  end
  historical_all << historical
  forecast_all << forecast

end

forecast_selected = [
  forecast_all[26], # S3
  forecast_all[12], # ECR
  forecast_all[10], # CloudSearch
  forecast_all[21], # RDS
  forecast_all[11], # DynamoDB
  forecast_all[9], # CloudFront
  forecast_all[13] # ElastiCache
]

# puts "Historical Total Cost in All Services: " + historical_all.inject{ |sum, i| sum + i }.to_s
puts "Forecast Cost in All Services: " + forecast_all.inject{ |sum, i| sum + i }.to_s

# SpreadSheet.ce_on_ss(forecast_selected) # スプレッドシートにコスト予報を出力
# puts forecast_selected
