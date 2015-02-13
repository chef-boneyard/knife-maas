require 'chef/knife/maas_base'

class Chef
  class Knife
    class MaasServerBootstrap < Knife

      include Chef::Knife::MaasBase

      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife maas server bootstrap (options)"

      option :hostname,
      :short => "-h HOSTNAME",
      :long => "--hostname HOSTNAME",
      :description => "The HOSTNAME inside of MaaS"

      option :system_id,
      :short => "-s SYSTEM_ID",
      :long => "--system-id SYSTEM_ID",
      :description => "The System ID inside of MaaS"

      def run
        hostname = locate_config_value(:hostname)
        response = access_token.request(:post, "/nodes/?op=acquire&name=#{hostname}")
        puts "Acquiring #{hostname} under your account now...."

        # hack to ensure the node have had time to spin up
        print(".")
        sleep 30
        print(".")

        system_id = locate_config_value(:system_id)
        response = access_token.request(:post, "/nodes/#{system_id}/?op=start")
        system_info = access_token.request(:get, "/nodes/#{system_id}/")
        puts "Starting up #{system_id} now...."

        # hack to ensure the nodes have had time to spin up
        print(".")
        sleep 30
        print(".")

        require 'pry'; binding.pry

        bootstrap_ip_address = JSON.parse(system_info.body)["ip_addresses"][0]
        server = JSON.parse(sys.body)["hostname"]

        print(".") until tcp_test_ssh(bootstrap_ip_address) {
          sleep @initial_sleep_delay ||= 10
          puts("done")
        }

        bootstrap_for_node(bootstrap_ip_address).run

      end


      def bootstrap_for_node(bootstrap_ip_address)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = bootstrap_ip_address
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = config[:ssh_user]
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
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

    end
  end
end