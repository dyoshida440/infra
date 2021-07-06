# README

このプロジェクトはインフラの構成をTerraform、OS/ミドルウェアの管理をAnsibleを用いて、
自分のインフラ知識の整理と今後のプロジェクトに活かせる構成のおさらいを目的に作成しています。

AWSのインフラ構成図は以下の通りです(created with draw.io)

# 手順
### インフラ構成の手順・コマンド
1. `$ terraform init`
2. `$ terraform plan`
3. `$ terraform apply`

※ 削除時 `$ terraform destroy`
※ tsstateファイルはS3で管理しています。

### Ansible実行
1. `$ ansible-playbook -i hosts production.yml`

### EC2へSSH接続
1. `$ cp database.yml.sample database.yml`
2. `$ vim database.yml`(db情報を追加)
3. ローカル環境からmaster.keyをコピーする
4. `$ bundle install`
5. `$ export RAILS_ENV=production`
6. `$ bundle exec rails db:create RAILS_ENV=production`
7. `$ bundle exec rails db:migrate RAILS_ENV=production`
8. `$ bundle exec unicorn_rails -c config/unicorn/production.rb -D -E production`
