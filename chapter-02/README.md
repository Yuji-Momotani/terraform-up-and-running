# 第2章 Terraformをはじめよう

## 到達目標

- `terraform init`, `fmt`, `validate`, `plan`, `apply`, `destroy` の役割を説明できる
- provider、resource、variable、output、resource attribute referenceを使える
- 1台のEC2からAuto Scaling GroupとApplication Load Balancerへ段階的に発展させられる
- planを読んで、作成・変更・削除の内容を判断できる
- 不要なAWSリソースとローカルの認証情報を残さず後片付けできる

## 進行

- [ ] 2.1 AWSアカウントのセットアップ
- [ ] 2.2 Terraformのインストール
- [ ] 2.3 サーバ1台のデプロイ
- [ ] 2.4 Webサーバ1台のデプロイ
- [ ] 2.5 設定変更可能なWebサーバのデプロイ
- [ ] 2.6 Webサーバのクラスタのデプロイ
- [ ] 2.7 ロードバランサのデプロイ
- [ ] 2.8 後片付け
- [ ] 2.9 まとめ・章末問題

## 安全ルール

1. AWSのアクセスキー、シークレットキー、セッショントークンを `.tf` や `.tfvars` に書かない。
2. `terraform apply` の前にplanのリソース数と主要属性を確認する。
3. 外部公開ポートはハンズオンに必要な最小範囲にする。
4. 作業終了時にAWSコンソールとTerraformの両方からリソース削除を確認する。
5. 意図しない変更や料金が疑われる場合は、applyせずに止まる。

