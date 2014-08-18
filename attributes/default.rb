# #-*- encoding : utf-8 -*-
# === VERSION AND LOCATION
default.elasticsearch[:version]       = "0.90.3"
default.elasticsearch[:host]          = "http://download.elasticsearch.org"
default.elasticsearch[:repository]    = "elasticsearch/elasticsearch"
default.elasticsearch[:filename]      = "elasticsearch-#{node.elasticsearch[:version]}.tar.gz"
default.elasticsearch[:download_url]  = [node.elasticsearch[:host], node.elasticsearch[:repository], node.elasticsearch[:filename]].join('/')

# === USER & PATHS
default.elasticsearch[:dir]       = "/data"
default.elasticsearch[:user]      = "elasticsearch"
default.elasticsearch[:home_dir]  = [node.elasticsearch[:dir], node.elasticsearch[:user]].join('/')
default.elasticsearch[:bin_dir]  = [node.elasticsearch[:home_dir], 'bin'].join('/')
default.elasticsearch[:command_path]  = [node.elasticsearch[:bin_dir], 'elasticsearch'].join('/')

default.elasticsearch[:path][:conf] = [node.elasticsearch[:home_dir], "config"].join('/')
default.elasticsearch[:path][:data] = [node.elasticsearch[:home_dir], "data"].join('/')
default.elasticsearch[:path][:plugins] = [node.elasticsearch[:home_dir], "plugins"].join('/')
default.elasticsearch[:path][:logs] = ['/var/log',node.elasticsearch[:user]].join('/')
default.elasticsearch[:path][:pids] = '/var/run'
default.elasticsearch[:pid_file]  = [node.elasticsearch[:path][:pids], "elasticsearch.pid"].join('/')

default.elasticsearch[:monit_dir] = "/etc/monit.d"

# === CLSUTER
default.elasticsearch[:cluster_name] = "elasticsearch"

# === MEMORY AND LIMITS
# Maximum amount of memory to use is automatically computed as one half of total available memory on the machine.
# You may choose to set it in your node/role configuration instead.
allocated_memory = "#{(node.memory.total.to_i * 0.6 ).floor / 1024}m"
default.elasticsearch[:allocated_memory] = allocated_memory

default.elasticsearch[:bootstrap][:mlockall] = ( node.memory.total.to_i >= 1048576 ? true : false )
default.elasticsearch[:limits][:memlock] = 'unlimited'
default.elasticsearch[:limits][:nofile]  = '64000'

default.elasticsearch[:thread_stack_size] = "256k"

# === NODE
default.elasticsearch[:node][:name] = "0"
default.elasticsearch[:node][:master] = nil
default.elasticsearch[:node][:data] = nil
default.elasticsearch[:node][:attributes] = {}

# === INDEX
default.elasticsearch[:index][:number_of_shards] = nil
default.elasticsearch[:index][:number_of_replicas] = nil

# === NETWORK
default.elasticsearch[:network][:bind_host] = nil
default.elasticsearch[:network][:publish_host] = nil
default.elasticsearch[:network][:host] = nil
default.elasticsearch[:transport][:tcp][:port] = nil
default.elasticsearch[:transport][:tcp][:compress] = nil
default.elasticsearch[:http][:port] = nil
default.elasticsearch[:http][:max_content_length] = nil
default.elasticsearch[:http][:enabled] = nil

# === GATEWAY / RECOVERY
default.elasticsearch[:gateway][:type] = nil
default.elasticsearch[:gateway][:recover_after_nodes] = nil
default.elasticsearch[:gateway][:recover_after_time] = nil
default.elasticsearch[:gateway][:expected_nodes] = nil
default.elasticsearch[:routing][:allocation][:node_concurrent_recoveries] = nil
default.elasticsearch[:indices][:recovery][:max_size_per_sec] = nil
default.elasticsearch[:indices][:recovery][:concurrent_streams] = nil

# === PLUGINS
default.elasticsearch[:plugins]            = {}
default.elasticsearch[:plugin][:mandatory] = []

