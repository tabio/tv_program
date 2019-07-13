## 概要
- TV番組表からキーワードに関連する番組を抽出しslackに通知するプログラム
- cronに設定して利用を想定

## 対応している番組表
- [Yahoo!テレビ](https://tv.yahoo.co.jp/)

## 利用方法
```rb
1. bundle install --path vendor/bundle
2. slackのwebhookの設定
3. bundle exec ruby notify_to_slack.rb
```
