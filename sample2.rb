require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'My Project'
CLIENT_SECRETS_PATH = '../Documents/credentials/client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "sheets.googleapis.com-ruby-quickstart.yaml")
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS # 読みとりと書き込み

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

sheet_service = Google::Apis::SheetsV4::SheetsService.new
sheet_service.client_options.application_name = 'nyaahara sama'
sheet_service.authorization = authorize


value_range = Google::Apis::SheetsV4::ValueRange.new
value_range.range = 'シート3!B5:J5'
value_range.major_dimension = 'ROWS'
value_range.values = [['にゃ','あ','は','ら']]

# example: https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
sheet_service.update_spreadsheet_value(
  '1n5kwTbKDjOEFnF3BJk6INvTvTaQPMa08T-irQSlvYkU',
  value_range.range,
  value_range,
  value_input_option: 'USER_ENTERED',
)
