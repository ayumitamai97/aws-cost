require_relative "gen_client"
include GenClient

GenClient.ce_client

start_day = Date.today.to_s.slice(0,8) + "01" # 月初
end_day = Date.today.to_s # 実行日の前日までのコストは、AWSではDate.todayまででよい
# ∵ end_dayを本日としてdailyコストを取得した場合、
#   各daily costが「1~2日」=1日の間、「2~3日」=2日、……「前日〜本日」=前日の間 となる

ce = Aws::CostExplorer::Client.new
services = ce.get_dimension_values({
  # search_string: "",
  time_period: { # required
    start: start_day, # required
  end: end_day, # required
  },
  dimension: "SERVICE", # required, accepts AZ, INSTANCE_TYPE, LINKED_ACCOUNT, OPERATION, PURCHASE_TYPE, REGION, SERVICE, USAGE_TYPE, USAGE_TYPE_GROUP, RECORD_TYPE, OPERATING_SYSTEM, TENANCY, SCOPE, PLATFORM, SUBSCRIPTION_ID, LEGAL_ENTITY_NAME, DEPLOYMENT_OPTION, DATABASE_ENGINE, CACHE_ENGINE, INSTANCE_TYPE_FAMILY
  context: "COST_AND_USAGE", # accepts COST_A7ND_USAGE, RESERVATIONS
  # next_page_token: "NextPageToken",
})

values = []



services.dimension_values.each do |service|
   values << service.value
end
puts values
