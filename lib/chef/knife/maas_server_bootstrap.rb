require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerBootstrap < Knife
      include Chef::Knife::MaasBase

      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner 'knife maas server bootstrap (options)'

      option :hostname,
             short: '-h HOSTNAME',
             long: '--hostname HOSTNAME',
             description: 'The HOSTNAME inside of MAAS'

      option :template_file,
             long: '--template-file TEMPLATE',
             description: 'Full path to location of template to use',
             proc: proc { |t| Chef::Config[:knife][:template_file] = t },
             default: false

      option :run_list,
             short: '-r RUN_LIST',
             long: '--run-list RUN_LIST',
             description: 'Comma separated list of roles/recipes to apply',
             proc: -> (o) { o.split(/[\s,]+/) },
             default: []

      option :zone,
             short: '-Z ZONE',
             long: '--zone ZONE',
             description: 'Bootstrap inside a ZONE inside of MAAS'

      option :bootstrap_timeout,
             short: '-T TIMEOUT',
             long: '--bootstrap-timeout',
             description: 'How long to wait for the Server to initially boot',
             default: 120

      def run
        node = acquire_node(hostname: locate_config_value(:hostname),
                            zone: locate_config_value(:zone)
                           )


        system_id = node['system_id']

        with_timeout(60) do
          # wait until node is in 'deployed' state
          wait_with_dots until client.list_node(system_id)['status'].to_s == '6'
        end

        with_timeout(60) do
          # wait until node is in 'deployed' state
          wait_with_dots until client.list_node(system_id)['status'].to_s == '6'
        end

        system_info = client.list_node(system_id)
        bootstrap_ip_address = system_info['ip_addresses'][0]

        with_timeout(config[:bootstrap_timeout]) do
          wait_with_dots(5) until tcp_test_ssh(bootstrap_ip_address)
        end

        case system_info['osystem']
        when 'centos'
          user = 'cloud-user'
        else
          user = 'ubuntu'
        end

        bootstrap_for_node(server, bootstrap_ip_address, user).run
      end

      def bootstrap_for_node(server, bootstrap_ip_address, user)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = bootstrap_ip_address
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] =  user
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        bootstrap.config[:chef_node_name] = server
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        bootstrap
      end

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        false
      rescue Errno::EHOSTUNREACH
        false
      rescue Errno::ENETUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end
    end
  end
end
