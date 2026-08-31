# resourceはTerraformが作成・変更・削除する対象ですが、dataは既存情報を読み取るだけです。
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
