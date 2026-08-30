# Terraform 学習進捗

最終更新: 2026-08-30

## 全体目標

- TerraformでAWSリソースをゼロから構築・変更・削除できる
- HCLとTerraform CLIの動作を説明できる
- エラーメッセージから原因を切り分けて修正できる
- state、module、secret、testing、team workflowのベストプラクティスを説明できる

## 現在地

- 進行中: 第2章「Terraformをはじめよう」
- 現在の節: 2.5 設定可能なWebサーバのデプロイ（完了）
- Terraform CLI: 1.15.8（darwin_arm64）をインストール済み。Homebrew tapのstable版として継続使用
- AWS CLI: 2.36.32（darwin arm64）をインストール済み
- Git: 2.39.5を確認済み
- AWSアカウント: rootで初期設定後、`administrator-user` IAMユーザーを作成済み
- AWSアカウント: developer IAMユーザーへ `PowerUserAccess` と `SignInLocalDevelopmentAccess` を付与済み。コンソールログイン確認済み
- AWS認証: `terraform-learning`プロファイルを作成済み。`login_session`による短期認証を使用
- AWSリージョン: `ap-northeast-1`

## 第2章チェックポイント

- [x] AWSアカウントの安全設定を確認する
- [x] AWSへの認証方式を決定する
- [x] Terraform CLIをインストールしてバージョンを確認する
- [x] AWS CLI v2をインストールしてバージョンを確認する
- [x] `aws sts get-caller-identity` で利用主体を確認する
- [x] EC2インスタンス1台の構成を理解してデプロイする
- [x] User DataでWebサーバを起動する
- [x] 入力変数と出力値を使う
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
- `.terraform/` はProvider・Module・backend初期化情報など、`terraform init`で再生成できるローカル作業データなのでGit管理しない。
- `.tfstate` は開発者ごとに異なってよいファイルではない。同じ管理対象には単一の正本stateが必要で、チームではロック・暗号化・アクセス制御を備えたremote backendで共有する。
- `.terraform.lock.hcl` は選択されたProviderバージョンとチェックサムを再現するためGit管理する。
- `resource "aws_instance" "example"` の `example` はTerraform内のローカル名で、resource address `aws_instance.example` の一部になる。AWS上の表示名には反映されない。
- AWS EC2コンソール上の名前は `tags.Name` によって設定される。resource labelの改名はstate addressの変更になるため、既存リソースでは `moved` block等を使って安全に行う。
- `user_data`でAmazon Linux 2023へApacheを導入し、`curl`で `Hello, World!` が返ることを確認した。
- `user_data_replace_on_change = true` により、user dataの追加・変更時にEC2が置換される。planの `-/+` と `forces replacement` を確認した。
- `aws_security_group.web.id` の属性参照から暗黙的依存関係が作られ、apply時にSecurity GroupがEC2より先に作成される。
- Security Groupルールは、現在のAWS Providerの推奨に合わせて `aws_vpc_security_group_ingress_rule` と `aws_vpc_security_group_egress_rule` で個別管理する。
- outbound用リソースを誤ってingressとして定義しても構文上は有効なため、`terraform validate`だけでは検出できない。planで方向・プロトコル・CIDRまで確認する必要がある。
- egressの `ip_protocol = "-1"` は全IPプロトコルを表す。`cidr_ipv4 = "0.0.0.0/0"` と組み合わせると、すべてのIPv4宛てへの送信通信を許可する。
- `server_port`を`number`型の入力変数として定義し、Security Group・Apacheの待受ポート・Web URLで共通利用した。
- HCLの式を直接受け取る引数では`var.server_port`と参照し、heredocなどの文字列内では`${var.server_port}`で補間する。
- 入力値は`default`、`-var`、`TF_VAR_<NAME>`などから渡せる。`-var`はそのコマンド実行時だけ値を上書きする。
- `number`型の`server_port`へ非数値を渡し、AWS APIを呼び出す前にTerraformが`Invalid value for input variable`を返すことを確認した。
- `output`はAWSリソースではないためPlanのリソース操作数には含まれないが、`Changes to Outputs`へ表示され、値はstateに記録される。
- `terraform output -raw web_url`を`curl`へ渡し、`Hello, World!`が返ることを確認した。

## 章末問題

未実施。

## 次回の開始点

2.6へ進み、Auto Scaling Groupを使ってWebサーバを複数台へ拡張する。
