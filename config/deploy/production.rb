set :stage, :production

server '18.177.169.225', user: 'ec2-user', roles: %w{app db web}, my_property: :my_value
server '54.249.154.187', user: 'ec2-user', roles: %w{app db web}, my_property: :my_value

set :ssh_options, keys: '~/.ssh/infra-key.pem' 

# before 'deploy:starting', 'deploy:upload'

# namespace :deploy do
#   task :restart do
#     invoke 'unicorn:restart'
#   end
#   desc 'Upload database.yml'
#   task :upload do
#     on roles([:app]) do |host|
#       if test "[ ! -d #{shared_path}/config ]"
#         execute "mkdir -p #{shared_path}/config"
#       end
#       upload!('config/database.yml', "#{shared_path}/config/database.yml")
#     end
#   end

#   after :restart, :clear_cache do
#     on roles(:app), in: :groups, limit: 3, wait: 10 do
#       within current_path do
#         with rails_env: fetch(:rails_env) do
#           execute :rake, 'tmp:cache:clear'
#         end
#       end
#     end
#   end
# end