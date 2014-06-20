[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

directory node[:elasticsearch][:path][:plugins] do
  owner node[:elasticsearch][:user]
  group node[:elasticsearch][:user]
  mode 0755
  recursive true
end

node[:elasticsearch][:plugins].each do | name, config |
  install_plugin name, config
end