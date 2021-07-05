# デプロイするアプリケーション名
set :application, 'infra'

# cloneするgitのレポジトリ
set :repo_url, 'https://github.com/dyoshida440/infra.git'

# deployするブランチ。デフォルトはmasterなのでなくても可。
set :branch, 'main'

# deploy先のディレクトリ。 
set :deploy_to, '/var/www/infra'

# シンボリックリンクをはるファイル。(※後述)
set :linked_files, fetch(:linked_files, []).push('config/settings.yml')

# シンボリックリンクをはるフォルダ。(※後述)
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# 保持するバージョンの個数(※後述)
set :keep_releases, 5

# rubyのバージョン
set :rbenv_type, :system
set :rbenv_ruby, '2.7.1'

# set :rbenv_path, '$HOME/deploy/.rbenv'

#出力するログのレベル。
set :log_level, :debug

# ※※※※※※※ この１行が重要 ※※※※※※※
set :linked_files, %w{config/database.yml}

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true
# set :linked_files, %w{config/master.key}
# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'Create database'
  task :db_create do
    on roles(:db) do |host|
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

end
