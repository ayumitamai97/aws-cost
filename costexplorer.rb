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

monthly_values = ["Amazon Simple Storage Service", "Amazon EC2 Container Registry (ECR)", "Amazon CloudSearch", "Amazon Relational Database Service", "Amazon DynamoDB", "Amazon CloudFront", "Amazon ElastiCache", "AWS CloudTrail", "AWS CodeCommit", "AWS Config", "AWS Data Pipeline", "AWS Database Migration Service", "AWS Key Management Service", "AWS Lambda", "AWS Support (Business)", "Amazon API Gateway", "EC2 - Other", "Amazon Elastic Compute Cloud - Compute", "Amazon Elastic Load Balancing", "Amazon Elastic MapReduce", "Amazon Elasticsearch Service", "Amazon QuickSight", "Amazon Rekognition", "Amazon Route 53", "Amazon Simple Email Service", "Amazon Simple Notification Service", "Amazon Simple Queue Service", "Amazon SimpleDB", "Amazon Virtual Private Cloud", "AmazonCloudWatch", "Tax"]
# all services

daily_values = ["Amazon ElastiCache"] # 1日の大きいコストによって予報をブレさせないため

def get_responses(granularity, values)
  ce = Aws::CostExplorer::Client.new

  start_day = Date.today.to_s.slice(0, 8) + "01" # 月初
  end_day = Date.today.to_s # 実行日の前日までのコストは、AWSではDate.todayまででよい
  # ∵ end_dayを本日としてdailyコストを取得した場合、
  #   各daily costが「1~2日」=1日の間、「2~3日」=2日、……「前日〜本日」=前日の間 となる
  past_days = end_day.slice(8, 9).to_i - start_day.slice(8, 9).to_i # 月初から前日までの日数
  last_day = Date.today.end_of_month.mday # 今月末の日付 (integerなので注意)

  keys = [ "Amazon Simple Storage Service", # 0
    "Amazon Elastic Block Store", # 1 # EC2-Otherにあたる # => "EC2"
    "Amazon Elastic Compute Cloud - Compute", # 2 # => "EC2"
    "Amazon Elastic Load Balancing", # 3 # => "EC2"
    "Amazon CloudSearch", # 4
    "Amazon Relational Database Service",# 5
    "Amazon DynamoDB", # 6
    "Amazon CloudFront", # 7
    "Amazon ElastiCache" ] # 8

  responses = ce.get_cost_and_usage(
    {
      time_period: {
        start: start_day, # required
        end: end_day # required
      },
      granularity: granularity, # accepts DAILY, MONTHLY
      filter: {
        dimensions: {
          key: "SERVICE",
          values: values
        }
      },
      metrics: ["BlendedCost"],
      group_by: [
        {
          type: "DIMENSION",
          key: "SERVICE"
        }
      ]
    }
  )
end

monthly_responses = get_responses("MONTHLY", monthly_values)
daily_responses = get_responses("DAILY", daily_values)
binding.pry

structs = monthly_responses.results_by_time[0]["groups"]

historicals_all = [] # 全サービスのHistorical Total
forecasts_particular = [] # "n月"シートに入力するコストの合計
forecasts_all = [] # 利用サービス全てのコストの合計

# puts monthly_responses.results_by_time

keys.each do |key|
  structs.each do |struct|
    # struct は object "Aws::CostExplorer::Types::GetDimensionValuesResponse"

    historical = struct["metrics"]["BlendedCost"].amount.to_f
    # puts "Historical Total: " + struct.keys[0] + ": " + historical.to_s
    # 各サービスのHistorical Total

    forecast_particular = (historical * (last_day - past_days) / past_days) if
     struct.keys[0] == key # 確認用

    historicals_all << historical
    forecasts_particular << forecast_particular.to_s

  end
end

# p forecasts_particular

structs.each do |struct|
  historical = struct["metrics"]["BlendedCost"].amount.to_f
  forecast_all = (historical * (last_day - past_days) / past_days)
  forecasts_all << forecast_all
end

forecasts_particular = forecasts_particular.reject!{ |e| e.empty? } # 二重のループでできてしまった空文字を取り除く

forecast_ec2 = forecasts_particular[2].to_f + forecasts_particular[3].to_f + forecasts_particular[4].to_f
forecasts_particular.slice!(1..3) # 2番目から要素3つ削除
forecasts_particular.insert(1, forecast_ec2) # 2番目にforecast_ec2(計算結果)を追加
forecasts_particular.insert(-1, "") # 末尾に空白(Otherの部分)を追加

forecasts_all_sum = forecasts_all.inject { |sum, i| sum + i }.to_s
forecasts_particular.insert(-1, forecasts_all_sum) # 末尾にforecasts_all_sum(計算結果)を追加

puts "Historical Total Cost in All Services: " + historicals_all.inject { |sum, i| sum + i }.to_s
puts "Forecast Cost in All Services: " + forecasts_all_sum

SpreadSheet.ce_on_ss(forecasts_particular) # スプレッドシートにコスト予報を出力
