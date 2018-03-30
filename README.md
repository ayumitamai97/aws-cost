# secretsの相対パス
## Google Spreadsheet
### path
../Documents/credentials/client_secret.json
### 中身
以下のようなURLからOAuth 2.0 クライアント IDをダウンロード  
https://console.developers.google.com/apis/credentials?project=northern-bot-199407&hl=ja

クライアントIDの取得を含むクイックスタートは以下  
https://developers.google.com/sheets/quickstart/ruby?hl=ja

## AWS
### path
../Documents/credentials/aws_credentials.json
### 中身
{  
  "Access key ID": "ほげ",  
  "Secret access key": "ふが"  
}

# 各ファイルの役割（備忘録）
## AWS関連
### aws_config.rb
AWSのリージョンやcredentialsの設定

### costexplorer.rb
AWS Cost Explorer APIを用いてコストを取得し、スプレッドシートに出力するまで  
週報作成時に使用。

### get_services.rb
使用しているサービス一覧を取得する  
月が変わって、使用しているサービスが変わった可能性があるときに使うかも…  
（加えて、月ごとにいちいちforecast_selected[num]のnumを変えないといけなさそう）

## Google Spreadsheet 関連
### authorize_ss.rb
クライアントシークレットなどの設定  
（公式ドキュメントからコピペしただけなので分からない）

### spreadsheet.rb
シートID、シート名、出力先セルなどの設定

##その他
### not_in_use/
使いません
