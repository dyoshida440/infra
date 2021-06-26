provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "infra-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  # 作成したVPCを参照し、そのVPC内にSubnetを立てる
  vpc_id = aws_vpc.main.id
  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "infra-subnet-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  # 作成したVPCを参照し、そのVPC内にSubnetを立てる
  vpc_id = aws_vpc.main.id
  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "infra-subnet-public-1c"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "infra-internet-gateway"
  }
}

# パブリックルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "infra-route-table"
  }
}

# パブリック用のルートテーブルのルート
# デフォルトルート(0.0.0.0/0)はインターネットゲートウェイにつなぐ
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

# パブリックサブネットとパブリックルートテーブルを紐付ける
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# パブリックサブネットとパブリックルートテーブルを紐付ける
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# 最新のAmazon Linux2のAMI IDを取得
data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "a" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  instance_type               = "t2.micro"
  key_name                    = "infra-key" // AWSコンソールで生成したキーペアの名前
  subnet_id                   = aws_subnet.public_1a.id
  security_groups             = [aws_security_group.infra.id]
  associate_public_ip_address = true

  tags = {
    Name = "infra-ec2-a"
  }
}

resource "aws_instance" "c" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  instance_type               = "t2.micro"
  key_name                    = "infra-key" // AWSコンソールで生成したキーペアの名前
  subnet_id                   = aws_subnet.public_1c.id
  security_groups             = [aws_security_group.infra.id]
  associate_public_ip_address = true

  tags = {
    Name = "infra-ec2-c"
  }
}

// セキュリティグループ
resource "aws_security_group" "infra" {
  name        = "infra-security-group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "infra-security-group"
  }
}

/// ssh
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.infra.id
}

/// インバウンドルール
resource "aws_security_group_rule" "tcp" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.infra.id
}

/// アウトバウンドルール
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.infra.id
}

resource "aws_eip" "a" {
  instance = aws_instance.a.id
  vpc = true

  tags = {
    Name = "infra-eip-a"
  }
}

resource "aws_eip" "c" {
  instance = aws_instance.c.id
  vpc = true

  tags = {
    Name = "infra-eip-c"
  }
}