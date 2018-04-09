module SpreadSheet
  require 'google/apis/sheets_v4'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require_relative "authorize_ss"
  require "date"

  def self.ce_on_ss(array) # Cost Explorer取得結果をスプレッドシートに出力
    include Authorize

    sheet_service = Google::Apis::SheetsV4::SheetsService.new
    sheet_service.authorization = authorize

    value_range = Google::Apis::SheetsV4::ValueRange.new
    this_month = Date.today.month.to_s
    value_range.range = "#{this_month}月!B5:J5"
    value_range.major_dimension = 'ROWS'
    value_range.values = [array]

    sheet_service.update_spreadsheet_value(
      '1fA-vQNKyigvruklRlFuwmctiHPOlXJmO4MbU1JYfaoY', # 週報用コストシート
      value_range.range,
      value_range,
      value_input_option: 'USER_ENTERED',
    )
  end

end
