module Extensions

  # Install an Elasticsearch plugin
  #
  # In the simplest form, just pass a plugin name in the GitHub <user>/<repo> format:
  #
  #     install_plugin 'karmi/elasticsearch-paramedic'
  #
  # You may also optionally pass a version:
  #
  #     install_plugin 'elasticsearch/elasticsearch-mapper-attachments', 'version' => '1.6.0'
  #
  # ... as well as the URL:
  #
  #     install_plugin 'hunspell', 'url' => 'https://github.com/downloads/.../elasticsearch-analysis-hunspell-1.1.1.zip'
  #
  # The "elasticsearch::plugins" recipe will install all plugins listed in
  # the role/node attributes or in the data bag (`node.elasticsearch.plugins`).
  #
  # Example:
  #
  #     { elasticsearch: {
  #         plugins: {
  #           'karmi/elasticsearch-paramedic' => {},
  #           'lukas-vlcek/bigdesk'           => { 'version' => '1.0.0' },
  #           'hunspell'                      => { 'url' => 'https://github.com/downloads/...' }
  #           'tom'                           => { 'git' => { 'repository' => '', revision => '', ssh_key => '' } }
  #         }
  #       }
  #     }
  #
  # See <http://wiki.opscode.com/display/chef/Setting+Attributes+(Examples)> for more info.
  #
  def install_plugin name, params={}
    
    if params['git']
      git_config = params['git']
      git_directory = "#{node[:elasticsearch][:home_dir]}/git"
      plugin_directory = "#{git_directory}/#{name}"

      git_wrapper_file = "#{plugin_directory}/git_wrapper.sh"
      ssh_key_file = nil
      plugin_source_directory = "#{plugin_directory}/source"

      # Create a directory for git and plugin
      directory plugin_directory do
        user node[:elasticsearch][:user]

        mode 0770
        recursive true
        action :create
      end

      if git_config.has_key?('ssh_key')
        # Use SSH key for connection to git
        ssh_key_file = "#{plugin_directory}/id_rsa"

        file ssh_key_file do
          user node[:elasticsearch][:user]
          mode 0600
          content git_config['ssh_key']
        end
      end

      template git_wrapper_file do
        source "git_wrapper.sh.erb"
        owner node[:elasticsearch][:user]

        variables ssh_key_file: ssh_key_file
        mode 0770
      end
      
      git plugin_source_directory do
        user node[:elasticsearch][:user]

        repository git_config['repository']
        revision git_config['revision']                   if git_config.has_key?('revision')
        enable_submodules git_config['enable_submodules'] if git_config.has_key?('enable_submodules')

        ssh_wrapper git_wrapper_file

        action :sync
      end

      url = "file://#{plugin_source_directory}"
    end

    ruby_block "Install plugin: #{name}" do
      block do
        version = params['version'] ? "/#{params['version']}" : nil
        url     = params['url']     ? " -url #{params['url']}" : nil

        command = "#{node[:elasticsearch][:bin_dir]}/plugin -install #{name}#{version}#{url}"
        Chef::Log.debug command

        raise "[!] Failed to install plugin" unless system command

        # Ensure proper permissions
        raise "[!] Failed to set permission" unless system "chown -R #{node[:elasticsearch][:user]}:#{node[:elasticsearch][:user]} #{node[:elasticsearch][:path][:plugins]}"
      end

      notifies :run, resources(:execute => "reload-monit") unless node[:elasticsearch][:skip_restart]
      
      not_if do
        Dir.entries(node[:elasticsearch][:path][:plugins]).any? do |plugin|
          next if plugin =~ /^\./
          name.include? plugin
        end rescue false
      end

    end

  end

end