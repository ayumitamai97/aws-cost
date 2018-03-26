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

cu = Aws::CostandUsageReportService::Client.new

resp = cu.describe_report_definitions({
  max_results: 5#,
  # next_token: "Daily costs",
})

puts resp
