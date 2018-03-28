require "aws-sdk"
require "aws-sdk-costexplorer"
require "json"
require "date"
require "pry"
require 'expanded_date'

module GenClient
  def ce_client
    creds = JSON.load(File.read("../Documents/credentials/aws_credentials.json")) # credentialsはファイル分ける
    Aws.config.update({
      region: "us-east-1", # ap-northeast-1はinvalid region
      credentials: Aws::Credentials.new(creds["Access key ID"], creds["Secret access key"])
    })
  end
end
