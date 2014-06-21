#-*- encoding : utf-8 -*-
elasticsearch = "elasticsearch-#{node[:elasticsearch][:version]}"
include_recipe "elasticsearch::packages"

# Create user and group
group node[:elasticsearch][:user] do
  action :create
end

user node[:elasticsearch][:user] do
  comment "ElasticSearch User"
  home    "/home/elasticsearch"
  shell   "/bin/bash"
  gid     node[:elasticsearch][:user]
  supports :manage_home => false
  action  :create
end

# Install ElasticSearch
script "install_elasticsearch" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    wget "#{node[:elasticsearch][:download_url]}"
    tar xvzf #{node[:elasticsearch][:filename]} -C #{node[:elasticsearch][:dir]}
    rm -f #{node[:elasticsearch][:home_dir]}
    ln -s "#{node[:elasticsearch][:home_dir]}-#{node[:elasticsearch][:version]}" #{node[:elasticsearch][:home_dir]}
  EOH
  not_if "ls #{node[:elasticsearch][:home_dir]}-#{node[:elasticsearch][:version]}"
end

# Create Symlink
link "#{node[:elasticsearch][:home_dir]}" do
  to "#{node[:elasticsearch][:home_dir]}-#{node[:elasticsearch][:version]}"
  not_if "ls #{node[:elasticsearch][:home_dir]}"
end
