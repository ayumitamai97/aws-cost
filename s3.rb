require "aws-sdk"
require "json"

creds = JSON.load(File.read("../Documents/credentials/aws_credentials.json"))# credentialsはファイル分ける
s3 = AWS::S3.new(
  :access_key_id => creds["Access key ID"],
  :secret_access_key => creds["Secret access key"]
)
