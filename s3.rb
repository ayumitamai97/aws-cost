require "aws-sdk"
require "json"

File.open("../Documents/credentials/aws_credentials.json") do |j| # credentialsはファイル分ける
  cred = JSON.load(j)
  s3 = AWS::S3.new(
    :access_key_id => cred["Access key ID"],
    :secret_access_key => cred["Secret access key"]
  )
end
