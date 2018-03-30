require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require "././authorize_ss"

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'My Project'
CLIENT_SECRETS_PATH = '../Documents/credentials/client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "sheets.googleapis.com-ruby-quickstart.yaml")
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS # 読みとりと書き込み

include Authorize

sheet_service = Google::Apis::SheetsV4::SheetsService.new
sheet_service.authorization = authorize

value_range = Google::Apis::SheetsV4::ValueRange.new
value_range.range = 'シート3!B5:J5'
value_range.major_dimension = 'ROWS'
value_range.values = [['optimizeaaaaaaaaaaa','あ','は','ら']]

sheet_service.update_spreadsheet_value(
  '1n5kwTbKDjOEFnF3BJk6INvTvTaQPMa08T-irQSlvYkU',
  value_range.range,
  value_range,
  value_input_option: 'USER_ENTERED',
)
