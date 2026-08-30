# Terraform 学習進捗

最終更新: 2026-08-27

## 全体目標

- TerraformでAWSリソースをゼロから構築・変更・削除できる
- HCLとTerraform CLIの動作を説明できる
- エラーメッセージから原因を切り分けて修正できる
- state、module、secret、testing、team workflowのベストプラクティスを説明できる

## 現在地

- 進行中: 第2章「Terraformをはじめよう」
- 現在の節: 2.3 サーバ1台のデプロイ（構成作成・plan）
- Terraform CLI: 1.15.8（darwin_arm64）をインストール済み。Homebrew tapのstable版として継続使用
- AWS CLI: 2.36.32（darwin arm64）をインストール済み
- Git: 2.39.5を確認済み
- AWSアカウント: rootで初期設定後、`administrator-user` IAMユーザーを作成済み
- AWSアカウント: developer IAMユーザーへ `PowerUserAccess` と `SignInLocalDevelopmentAccess` を付与済み。コンソールログイン確認済み
- AWS認証: `terraform-learning`プロファイルを作成済み。`login_session`による短期認証を使用
- AWSリージョン: 未決定

## 第2章チェックポイント

- [x] AWSアカウントの安全設定を確認する
- [x] AWSへの認証方式を決定する
- [x] Terraform CLIをインストールしてバージョンを確認する
- [x] AWS CLI v2をインストールしてバージョンを確認する
- [x] `aws sts get-caller-identity` で利用主体を確認する
- [x] EC2インスタンス1台の構成を理解してデプロイする
- [ ] User DataでWebサーバを起動する
- [ ] 入力変数と出力値を使う
- [ ] Auto Scaling Groupを使う
- [ ] Application Load Balancerを使う
- [ ] 全リソースを安全に削除する
- [ ] 第2章の章末問題に回答する

## 理解・エラー記録

- `tf` はシェルで設定された `terraform` のエイリアス。
- Terraform本体は `/opt/homebrew/bin/terraform` にインストールされている。
- 講座では公式ドキュメントと表記を合わせるため `terraform` コマンドを使用する。
- Terraform本体は1.16.0を最新版として通知したが、2026-08-27時点のHashiCorp Homebrew tapはstable 1.15.8。学習に必要な機能を満たすため1.15.8を継続使用する。
- AWS CLI 2.36.32は `~/.local/bin/aws` にインストールされている。
- IAMポリシーは加算される。developerユーザーに `AdministratorAccess` があるため、現状は実質的に管理者である。
- `AdministratorAccess` はBedrock操作も包含するため、同時に付与された `AmazonBedrockFullAccess` は現状では冗長である。
- developerユーザーの権限を `PowerUserAccess` と `SignInLocalDevelopmentAccess` へ変更した。
- `~/.aws/config` の `[profile terraform-learning]` は `login_session` を参照し、デフォルトリージョンとして `ap-northeast-1` を使用する。
- `aws sts get-caller-identity` で `user/developer` として認証されることを確認した。
- `aws configure list` で認証情報の取得元が `login`、リージョンの取得元が `~/.aws/config` であることを確認した。
- `chapter-02/01-single-server/main.tf` から `aws_instance.example` を作成し、ローカルstateに記録されていることを確認した。
- AWS ProviderのprofileをHCLで指定しない場合、`AWS_PROFILE`などの認証情報チェーンから選択される。stateには実行時のprofile名は保存されない。
- EC2へ `Environment = "learning"` タグを適用し、HCLとローカルstateの両方に存在することを確認した。
- planの属性行に付く `+` は追加、`-` は削除を表す。リソース全体の `~` はin-place更新を表す。

## 章末問題

未実施。

## 次回の開始点

適用後のplanが `No changes` になることを確認する。その後Gitを初期化し、HCLとlock fileは追跡し、stateと`.terraform`は除外する。
