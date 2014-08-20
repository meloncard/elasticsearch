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
      ssh_key_file = nil

      # Allow SSH key connection to git
      if git_config.has_key?('ssh_key')
        ssh_key_file = "#{Chef::Config[:file_cache_path]}/#{name}_id_rsa"

        file ssh_key_file do
          user node[:elasticsearch][:user]
          mode "0600"
          content git_config['ssh_key']
        end
      end

      file_location = "#{Chef::Config[:file_cache_path]}/#{name}"
      
      git file_location do
        user node[:elasticsearch][:user]
        repository git_config['repository']
        revision git_config['revision']                   if git_config.has_key?('revision')
        enable_submodules git_config['enable_submodules'] if git_config.has_key?('enable_submodules')
        ssh_wrapper "ssh -i #{ssh_key_file}"              if ssh_key_file

        action :sync
      end

      url = "file://#{file_location}"
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