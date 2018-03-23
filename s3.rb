require "aws-sdk"
require "aws-sdk-s3"
require "json"

creds = JSON.load(File.read("../Documents/credentials/aws_credentials.json")) # credentialsはファイル分ける
Aws.config.update({
  region: "ap-northeast-1",
  credentials: Aws::Credentials.new(creds["Access key ID"], creds["Secret access key"])
})
s3 = Aws::S3::Client.new
resp = s3.list_buckets
puts resp.buckets.map(&:name) # おためし
